// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "./DotcStorage.sol";

contract DotcMain is Initializable, OwnableUpgradeable, DotcStorage {
	
    using SafeMathUpgradeable for uint256;

    function initialize(address oracleAddress, address usdtAddress, address usdcAddress, address daiAddress) public initializer {
	oracle = PriceOracle(oracleAddress);

	//allTokens.push(Token({symbol:"USDT", addr:usdtAddress}));
        //tokenMap[usdtAddress] = Token({symbol:"USDT", addr:usdtAddress});
        usdt = ERC20Upgradeable(usdtAddress);

        //allTokens.push(Token({symbol:"USDC", addr:usdcAddress}));
        //tokenMap[usdcAddress] = Token({symbol:"USDC", addr:usdcAddress});
        usdc = ERC20Upgradeable(usdcAddress);

        //allTokens.push(Token({symbol:"DAI", addr:daiAddress}));
        //tokenMap[daiAddress] = Token({symbol:"DAI", addr:daiAddress});
        dai = ERC20Upgradeable(daiAddress);

	__Ownable_init();

	//fee_wallet = payable(owner());

	customerAdmin = 0xe3Ab2169570D4a7d7641958C92c67c2F2522A3dC;
    }



    // 用户从钱包充值到dotc合约
    function deposit(address token, uint256 amount) public {
	//require(amount <= ERC20Upgradeable(token).balanceOf(msg.sender));
	ERC20Upgradeable(token).transferFrom(msg.sender, address(this), amount);
	user_balances[msg.sender][token] = user_balances[msg.sender][token].add(amount);
	emit TokenDeposited(token, msg.sender, amount);
    }

    //用户批量把资产从抵押提取到dotc账户
    //side=1: 卖单
    //side=2: 买单
    //最多支持5个订单
    function batch_withdraw_collateral(uint[] memory sides, uint256[] memory order_ids) public {
	address account = msg.sender;
	require(sides.length == order_ids.length && sides.length > 0, "OUT BOUND");
	uint40 frozen_span = uint40(frozen_times[account]);
	for(uint j =0; j<sides.length; j++)
	{
		uint side = sides[j];
		uint256 order_id = order_ids[j];
		if(side == 1)
		{
			require(adMaps[order_id].status == 3);
			require(block.timestamp-adMaps[order_id].place_time >= frozen_span);

			Collateral[] memory cols = sellerCollateral[account][order_id];
			for(uint256 i=0; i<cols.length; i++)
			{
				if(cols[i].token_amount > 0)
					user_balances[account][cols[i].token.addr] = user_balances[account][cols[i].token.addr].add(cols[i].token_amount);
			}
			delete sellerCollateral[account][order_id];
		}else if(side == 2)
		{
			require(isReleasable(account, order_id));
			
			Collateral[] memory cols = buyerCollateral[account][order_id];
			for(uint256 i=0; i<cols.length; i++)
			{
				if(cols[i].token_amount > 0)
					user_balances[account][cols[i].token.addr] = user_balances[account][cols[i].token.addr].add(cols[i].token_amount);
			}
			delete buyerCollateral[account][order_id];
		}
	}
    }

    // 批量质押 
    function batch_collateral(address[] memory collateral_tokens, uint256[] memory collateral_wallet_values) public returns (bool){
	require(collateral_tokens.length>0 && collateral_tokens.length == collateral_wallet_values.length);
	for(uint i=0; i<collateral_tokens.length; i++)
	{
		address token_addr = collateral_tokens[i];
		if(collateral_wallet_values[i]>0)
		{
			ERC20Upgradeable(token_addr).transferFrom(msg.sender, address(this), collateral_wallet_values[i]);
			user_balances[msg.sender][token_addr] = user_balances[msg.sender][token_addr].add(collateral_wallet_values[i]);
			emit TokenDeposited(token_addr, msg.sender, collateral_wallet_values[i]);
		}
	}
	return true;
    }
    // 批量提现
    function batch_withdraw(address[] memory tokens, uint256[] memory values) public returns (bool){
	require(tokens.length>0 && tokens.length == values.length);
	for(uint i=0; i<tokens.length; i++)
	{
		address token_addr = tokens[i];
		if(values[i]>0)
		{
			//require(user_balances[msg.sender][token_addr]>=values[i]);
			user_balances[msg.sender][token_addr] = user_balances[msg.sender][token_addr].sub(values[i]);
			ERC20Upgradeable(token_addr).transfer(msg.sender, values[i]);
			emit TokenWithdrawn(token_addr, msg.sender, values[i]);
		}
	}
	return true;
    }
    /**  
     * 新广告订单
     * token - 要售卖的Token合约地址
     * fiat_price - CNY价格, 这里传最低出售价格，精度18
     * dotc_amount - 从DOTC账户里导入的数量 
     * low_limit - 最低限额，单位CNY，小数点后2位，这里精度是18
     * high_limit - 最高限额，单位CNY，小数点后2位，这里精度是18
     * collateral_tokens - 抵押资产的合约地址[这里是数组后面的值要跟这里一一对齐，否则会出错]
     * collateral_dotc_values - 来自DOTC账户抵押资产的数量, 要跟前面的collateral_tokens数组对齐
     *
     */
    function new_sell_ad_order(address token_addr, uint256 fiat_price, uint256 low_limit, uint256 high_limit, uint256 dotc_amount, address[] memory collateral_tokens, uint256[] memory collateral_dotc_values) public returns (uint256){
	require(is_stop == false, "SYS STOP");
	require(isListed(token_addr), "NO LIST");
	require(token_addr != address(0), "0x0");
	require(fiat_price > 0, "PRICE 0");
	require(low_limit>0 && high_limit>0 && high_limit>low_limit, "LIMITS");
	require(dotc_amount >= minAdQuantityMantissa, "MIN AD QUANT");
	require(collateral_tokens.length>0 && collateral_tokens.length == collateral_dotc_values.length, "WRONG COLLATERAL");

	require(user_balances[msg.sender][token_addr] >= dotc_amount, "INSUF BAL");
	total_ad_num = total_ad_num.add(1);

	for(uint i=0; i<collateral_tokens.length; i++)
	{
		Token memory tk = tokenMap[collateral_tokens[i]];
		//require(user_balances[msg.sender][tk.addr] >= collateral_dotc_values[i], "INSUF COL");
		user_balances[msg.sender][tk.addr] = user_balances[msg.sender][tk.addr].sub(collateral_dotc_values[i]);
		if(tk.addr == token_addr)
		{
			//require(user_balances[msg.sender][token_addr] >= dotc_amount, "INSUF BAL");
			user_balances[msg.sender][token_addr] = user_balances[msg.sender][token_addr].sub(dotc_amount);
		}
		Collateral[] storage collateral = sellerCollateral[msg.sender][total_ad_num];
		collateral.push(Collateral({token:tk, token_amount:collateral_dotc_values[i]}));
	}

	adMaps[total_ad_num] = Ad({
		ad_id: total_ad_num,
		token: token_addr,
		token_amount: dotc_amount,
		fiat_price: fiat_price,
		low_limit: low_limit,
		high_limit: high_limit,
		status: 1,
		place_time: uint40(block.timestamp)
	});
	userAdsMap[msg.sender].push(total_ad_num);

    	emit NewAdOrder(token_addr, msg.sender, total_ad_num, fiat_price, low_limit, high_limit, dotc_amount, collateral_tokens, collateral_dotc_values);
	return total_ad_num;
    }

    function _new_order(address seller_addr, uint256 ad_id, address buyer_addr, address token_addr, uint256 token_amount, uint256 token_price) internal returns (uint256) {

	Ad storage ad = adMaps[ad_id];
	require(ad.status == 1 || ad.status == 2, "NOT COMPLETE");

	total_order_num = total_order_num.add(1);
	ad.token_amount = ad.token_amount.sub(token_amount);
	if(ad.token_amount == 0)
	{
		ad.status = 3;
		uint ind = 0;
		for(uint i=0; i<userAdsMap[seller_addr].length; i++)
			if(userAdsMap[seller_addr][i] == ad_id)
				ind = i;
		delete userAdsMap[seller_addr][ind];
	}else
		ad.status = 2;
	
	//charge fee
	uint256 taker_fee = token_amount.mul(takerFeeRatioMantissa).div(1e18);
	ERC20Upgradeable(token_addr).transfer(fee_wallet, taker_fee);
	uint256 maker_fee = token_amount.mul(makerFeeRatioMantissa).div(1e18);
	ERC20Upgradeable(token_addr).transfer(fee_wallet, maker_fee);

	orderMaps[total_order_num] = Order ({
		order_id: total_order_num,
		seller: seller_addr,
	        buyer: buyer_addr,
		token: token_addr,
		token_amount: token_amount.sub(taker_fee),
		price: token_price,
		status: 1,
		open_time: uint40(block.timestamp),
		close_time: 0	
	});
	userOrdersMap[buyer_addr].push(total_order_num);
	userOrdersMap[seller_addr].push(total_order_num);
	user_balances[msg.sender][token_addr] = user_balances[msg.sender][token_addr].add(token_amount);
   	return total_order_num; 
    }
    //seller撤单
    function seller_cancel_order(uint256 ad_id) public returns (uint256) {
	Ad storage ad = adMaps[ad_id];
	address seller_addr = msg.sender;
	uint ind = 0;
	bool is_contains = false;
	for(uint i=0; i<userAdsMap[seller_addr].length; i++)
	{
		if(userAdsMap[seller_addr][i] == ad_id)
		{
			ind = i;
			is_contains = true;
			break;
		}
	}
	require(is_contains == true, "NO AD ORDER");

	if(ad.token_amount == 0)
	{
		ad.status = 3;
		delete userAdsMap[seller_addr][ind];
		return 0;
	}else
		ad.status = 4;
	
	//charge fee
	uint256 fee = ad.token_amount.mul(sellerPenaltyRatioMantissa).div(1e18);
	if(fee > 0)
		ERC20Upgradeable(ad.token).transfer(fee_wallet, fee);

	user_balances[msg.sender][ad.token] = user_balances[msg.sender][ad.token].add(ad.token_amount.sub(fee));
   	return ad.token_amount.sub(fee); 
    }

    /**  
     * 新买单订单，这里只考虑Taker的情况
     * token - 要购买的Token合约地址
     * buy_price - CNY价格, 精度18
     * buy_amount - 目标token的数量 
     * collateral_tokens - 抵押资产的合约地址[这里是数组后面的值要跟这里一一对齐，否则会出错]
     * collateral_dotc_values - 来自DOTC账户抵押资产的数量, 要跟前面的collateral_tokens数组对齐
     *
     */
    function new_buy_order(address token_addr, uint256 buy_price, uint256 buy_amount, address seller_addr, uint256 sell_ad_id, address[] memory collateral_tokens, uint256[] memory collateral_dotc_values) public returns (uint256){
	require(is_stop == false, "SYS STOP");
	require(isListed(token_addr), "NO LIST");
	require(seller_addr != address(0));
	require(buy_price > 0, "PRICE 0");
	require(buy_amount > 0, "<=0");
	require(collateral_tokens.length>0 && collateral_tokens.length == collateral_dotc_values.length, "WRONG CLLATERAL");

	require(adMaps[sell_ad_id].token == token_addr, "WRONG TOKEN");
	//如果Ad不足，则按照剩余数量成交，则buy_amount需要更新
	require(adMaps[sell_ad_id].token_amount >= buy_amount, "INSUF SELL");
	require(buy_price >= adMaps[sell_ad_id].fiat_price, "W PRICE");
	uint256 decimal = ERC20Upgradeable(token_addr).decimals();
	require(buy_amount.mul(buy_price).div(10**decimal)>=adMaps[sell_ad_id].low_limit && buy_amount.mul(buy_price).div(10**decimal)<=adMaps[sell_ad_id].high_limit, "LIMIT");

	// check is over, start to create new buy order.
	for(uint i=0; i<collateral_tokens.length; i++)
	{
		Token memory tk = tokenMap[collateral_tokens[i]];
		//require(user_balances[msg.sender][tk.addr] >= collateral_dotc_values[i], "INSUF COL");
		user_balances[msg.sender][tk.addr] = user_balances[msg.sender][tk.addr].sub(collateral_dotc_values[i]);
		Collateral[] storage collateral = buyerCollateral[msg.sender][total_ad_num];
		collateral.push(Collateral({token:tk, token_amount:collateral_dotc_values[i]}));
	}
	uint256 order_id = _new_order(seller_addr, sell_ad_id, msg.sender, token_addr, buy_amount, buy_price);

    	emit NewSellOrder(token_addr, seller_addr, order_id, buy_price, buy_amount);
    	emit NewBuyOrder(token_addr, msg.sender, order_id, buy_price, buy_amount, collateral_tokens, collateral_dotc_values);
	return order_id;
    }

    /// @notice Buyer cancel the order
    function buyer_cancel_order(uint256 order_id) external {
	require(is_stop == false, "SYS STOP");
    	require(order_id <= total_order_num, "OUT BOUND");
	Order storage order = orderMaps[order_id];
	require(order.order_id == order_id, "NO MATCH");
	require(order.status == 1, "UNPAID ONLY");
	
	order.status = 4;
	order.close_time = uint40(block.timestamp);
	uint256 penalty = order.token_amount.mul(buyerPenaltyRatioMantissa).div(1e18);
	ERC20Upgradeable(order.token).transfer(fee_wallet, penalty);
	
	//FIXME: 假如用户没有当前订单里的币作为质押呢？什么顺序扣罚金呢？扣多少呢？
    	emit OrderCanceled(order.token, order.buyer, order.order_id, order.price, order.token_amount);
    }

    /// @notice Buyer labels order to "paid"
    /// @dev -
    function buyer_label_paid(uint256 order_id) external {
	require(is_stop == false, "SYS STOP");
	Order storage order = orderMaps[order_id];
	require(order.order_id == order_id, "WRONG ID");
	//require(order.status != 4 && order.status != 5 && order.status != 6, "UNCOMPLETED ONLY");
	order.status = 2;
	order.close_time = uint40(block.timestamp);
	
    	emit OrderPaidBuyer(order.token, order.buyer, order.order_id, order.price, order.token_amount);
    }

    /// @notice Buyer labels order to arbitration
    /// @dev -
    function buyer_label_arbitration(uint256 order_id, uint40 status, string memory reason) external {
	require(is_stop == false, "SYS STOP");
	Order storage order = orderMaps[order_id];
	require(order.order_id == order_id, "WRONG ID");
	//require(order.status != 4 && order.status != 5 && order.status != 6, "UNCOMPLETED ONLY");
	order.status = status;
    	
	emit OrderArbitrationBuyer(order.token, order.buyer, order_id, order.price, order.token_amount, status, reason);
    }

    /// @notice Seller labels order to arbitration
    /// @dev -
    function seller_label_arbitration(uint256 order_id, uint40 status, string memory reason) external {
	require(is_stop == false, "SYS STOP");
	Order storage order = orderMaps[order_id];
	require(order.order_id == order_id, "WRONG ID");
	//require(order.status != 4 && order.status != 5 && order.status != 6, "UNCOMPLETED ONLY");
	order.status = status;

    	emit OrderArbitrationSeller(order.token, order.seller, order_id, order.price, order.token_amount, status, reason);
    }
    
    // @notice get all tokens  
    function getAllTokens() external view returns (Token [] memory)
    {
	    return allTokens;
    }
    // @notice get length of token list
    function getAllTokensLength() external view returns (uint)
    {
	    return allTokens.length;
    }

    //获取仲裁状态
    function getArbitrationStatus(uint256 order_id) public view returns (uint40){
	Order storage order = orderMaps[order_id];
	return order.status;
    }

    /*
     *   Only external call
     */
    //获得用户的买单质押资产列表
    function getUserBuyCollateralList(address account, uint256 order_id) view external returns (Collateral[] memory) {
    	return buyerCollateral[account][order_id];
    }
    //获得用户的卖单质押资产列表
    function getUserSellCollateralList(address account, uint256 order_id) view external returns (Collateral[] memory) {
    	return sellerCollateral[account][order_id];
    }
    //获得用户的卖单详情
    function getUserSellAdInfo(uint256 order_id) view external returns (Ad  memory) {
    	return adMaps[order_id];
    }
    //获得用户的订单详情
    function getUserBuyOrderInfo(uint256 order_id) view external returns (Order  memory) {
    	return orderMaps[order_id];
    }
    //获得用户的卖单记录相关数组
    function getUserAdOrderList(address account) view external returns (uint256[] memory) {
    	return userAdsMap[account];
    }
    //获得用户的订单记录相关数组
    function getUserOrderList(address account) view external returns (uint256[] memory) {
    	return userOrdersMap[account];
    }
    //获得用户的惩罚记录相关数组
    function getUserPenaltyOrderList(address account) view external returns (uint256[] memory) {
    	return userPenaltyMap[account];
    }
    //获得用户某个token的可用余额，因为时间变化，只能实时获取。
    function getTokenAvailableAmount(address token, address account) view internal returns(uint256) {
	uint256 amount = user_balances[account][token];
	if(total_order_num > 0)
	{
		for(uint i=0; i<userOrdersMap[account].length; i++)
		{
			uint256 order_id = userOrdersMap[account][i];
			Order storage order = orderMaps[order_id];
			if(order.token != token)
				continue;
			if(account == order.buyer)
			{
				if(!isReleasable(account, i))
					continue;
				for(uint j=0; j<buyerCollateral[account][i].length; j++)
				{
					if(token != buyerCollateral[account][i][j].token.addr)
						continue;
					amount = amount.add(buyerCollateral[account][i][j].token_amount);
				}				
			}
			if(account == order.seller)
			{
				if(!isReleasable(account, i))
					continue;
				for(uint j=0; j<sellerCollateral[account][i].length; j++)
				{
					if(token != sellerCollateral[account][i][j].token.addr)
						continue;
					amount = amount.add(sellerCollateral[account][i][j].token_amount);
				}				
			}
		}	
	}
	return amount;
    }
    //获得用户的所有现货列表以及余额（symbol, address, balance）
    function getUserTokenList(address account) view external returns (string[] memory symbols, address[] memory addrs, uint256[] memory amounts) {
	uint len = allTokens.length;
	if(len>0)
	{
		symbols = new string[](len);
		addrs = new address[](len);
		amounts = new uint256[](len);
		for(uint i=0; i<len; i++)
		{
			symbols[i] = allTokens[i].symbol;
			addrs[i] = allTokens[i].addr;
			amounts[i] = getTokenAvailableAmount(allTokens[i].addr, account); 
		}
	}
    }
    //获得用户某个账户的抵押资产额度(USD)
    function getAccountCollateral(address account) view external returns(uint256) {
	uint256 amount = 0;
	if(total_order_num > 0)
	{
		for(uint i=0; i<userOrdersMap[account].length; i++)
		{
			uint256 order_id = userOrdersMap[account][i];
			Order storage order = orderMaps[order_id];
			if(account == order.buyer)
			{
				if(isReleasable(account, i))
					continue;
				for(uint j=0; j<buyerCollateral[account][order_id].length; j++)
				{
					uint price = oracle.getPrice(buyerCollateral[account][order_id][j].token.addr);
					amount = amount.add(buyerCollateral[account][order_id][j].token_amount.mul(price).div(1e18));
				}				
			}
			if(account == order.seller)
			{
				if(isReleasable(account, i))
					continue;
				for(uint j=0; j<sellerCollateral[account][order_id].length; j++)
				{
					uint price = oracle.getPrice(sellerCollateral[account][order_id][j].token.addr);
					amount = amount.add(sellerCollateral[account][order_id][j].token_amount.mul(price).div(1e18));
				}				
			}
		}	
	}
	return amount;
    }
    //获得用户某个账户正在交易中的资产额度(USD)
    function getAccountTradingAssets(address account) view external returns(uint256) {
	uint256 amount = 0;
	if(total_order_num > 0)
	{
		for(uint i=0; i<userOrdersMap[account].length; i++)
		{
			uint256 order_id = userOrdersMap[account][i];
			Order storage order = orderMaps[order_id];
			if(order.status == 1)
			{
				uint price = oracle.getPrice(order.token);
				amount = amount.add(order.token_amount.mul(price).div(1e18));
			}
		}	
	}
	return amount;
    }
    //抵押是否可释放
    function isReleasable(address account, uint256 order_id) view internal returns (bool)
    {
	uint40 frozen_span = uint40(frozen_times[account]);
	if((orderMaps[order_id].close_time !=0)&&(block.timestamp-orderMaps[order_id].close_time >= frozen_span))
		return true;
	return false;
    } 
    /***********************************|
    |        Whitelist Functions         |
    |__________________________________*/
    function addWhitelist(address _addWhitelist) public onlyOwner returns (bool) {
        require(_addWhitelist != address(0), "INVALID ADDR");
        return EnumerableSetUpgradeable.add(_whitelist, _addWhitelist);
    }

    function delWhitelist(address _delWhitelist) public onlyOwner returns (bool) {
        require(_delWhitelist != address(0), "INVALID ADDR");
        return EnumerableSetUpgradeable.remove(_whitelist, _delWhitelist);
    }

    function getWhitelistLength() public view returns (uint256) {
        return EnumerableSetUpgradeable.length(_whitelist);
    }

    function isWhitelist(address account) public view returns (bool) {
        return EnumerableSetUpgradeable.contains(_whitelist, account);
    }

    function getWhitelist(uint256 _index) public view onlyOwner returns (address){
        require(_index <= getWhitelistLength() - 1, "OUT BOUND");
        return EnumerableSetUpgradeable.at(_whitelist, _index);
    }

    // modifier for mint function
    modifier onlyWhitelist {
        require(isWhitelist(msg.sender), "WHITELIST ONLY");
        _;
    }
    /**
     * Admin operations
     */
    //添加新的可交易资产
    function _addToken(string memory symbol, address tokenAddress) onlyOwner external {
	require(!isListed(tokenAddress), "LISTED");
        allTokens.push(Token({symbol:symbol, addr:tokenAddress}));
        tokenMap[tokenAddress] = Token({symbol:symbol, addr:tokenAddress});
	emit NewTokenAdded(tokenAddress, symbol);
    }
    //设置Orcale
    function _setOracle(address oracleAddress) onlyOwner external {
        address oldOracle = address(oracle);
	oracle = PriceOracle(oracleAddress);
	emit NewOracle(oldOracle, oracleAddress);
    }

    //设置是否停止系统
    function _setIsStop(bool isStop) onlyOwner external {
	    is_stop = isStop;
    }

    //设置卖单最小金额
    function _setAdQuantityMantissa(uint256 limit) onlyOwner external {
	minAdQuantityMantissa = limit;
    }
   
    //设置买方撤单罚没比例
    function _setBuyerPenaltyRatioMantissa(uint256 ratio) onlyOwner external {
	buyerPenaltyRatioMantissa = ratio;
    }

    //设置卖方撤单罚没比例
    function _setSellerPenaltyRatioMantissa(uint256 ratio) onlyOwner external {
	sellerPenaltyRatioMantissa = ratio;
    }

    //设置买方抵押额度
    function _setBuyerCollateralRatioMantissa(uint256 ratio) onlyOwner external {
	buyerCollateralRatioMantissa = ratio;
    }

    //设置卖方抵押额度
    function _setSellerCollateralRatioMantissa(uint256 ratio) onlyOwner external {
	sellerCollateralRatioMantissa = ratio;
    }

    //设置taker手续费
    function _setTakerFeeRatioMantissa(uint256 ratio) onlyOwner external {
	takerFeeRatioMantissa = ratio;
    }

    //设置maker手续费
    function _setMakerFeeRatioMantissa(uint256 ratio) onlyOwner external {
	makerFeeRatioMantissa = ratio;
    } 

    //设置买方24h未付款惩罚比例
    function _setBuyerUnpayPenaltyRatioMantissa(uint256 ratio) onlyOwner external {
	buyerUnpayPenaltyRationMantissa = ratio;
    }

    //设置卖方卡有问题惩罚比例
    function _setSellerCardPenaltyRatioMantissa(uint256 ratio) onlyOwner external {
	sellerCardRatioMantissa = ratio;
    }

    //设置买方申诉失败惩罚
    function _setBuyerFailedArbitrationMantissa(uint256 ratio) onlyOwner external {
    	buyerFailedArbitrationMantissa = ratio;
    }

    //设置卖方申诉失败惩罚
    function _setSellerFailedArbitrationMantissa(uint256 ratio) onlyOwner external {
    	sellerFailedArbitrationMantissa = ratio;
    }

    //设置买方黑钱惩罚
    function _setBuyerBlackMoneyPenaltyMantissa(uint256 ratio) onlyOwner external {
    	buyerBlackMoneyPenaltyMantissa = ratio;
    }

    //设置卖方黑U惩罚
    function _setSellerBlackUPenaltyMantissa(uint256 ratio) onlyOwner external {
	    sellerBlackUPenaltyMantissa = ratio;
    }

    //设置手续费接收钱包
    function _setFeeWallet(address payable wallet) onlyOwner external {
	fee_wallet = wallet;
    }

    //设置仲裁客服钱包
    function _setCustomerAdminWallet(address cAdmin) onlyOwner external {
	customerAdmin = cAdmin;
    }

    //管理员设置仲裁状态
    function _setArbitrationStatus(uint256 order_id, uint40 status, bool is_match, address[] memory buyer_collateral_tokens, uint256[] memory buyer_values, address[] memory seller_collateral_tokens, uint256[] memory seller_values) external {
	require(msg.sender == customerAdmin, "ADMIN ONLY");
	Order storage order = orderMaps[order_id];
	require(order.order_id == order_id, "WRONG ID");
	order.status = status;

	Collateral[] storage b_cols = buyerCollateral[order.buyer][order_id];
	for(uint i=0; i<b_cols.length; i++)
	{
		for(uint j=0; j<buyer_collateral_tokens.length; j++)
		{
			if(b_cols[i].token.addr == buyer_collateral_tokens[j])
			{
				//require(b_cols[i].token_amount >= buyer_values[j], "INSUF COL");
				b_cols[i].token_amount = b_cols[i].token_amount.sub(buyer_values[j]);
			}
		}
	}
	if(buyer_collateral_tokens.length > 0)
		userPenaltyMap[order.buyer].push(order_id);
	Collateral[] storage s_cols = sellerCollateral[order.seller][order_id];
	for(uint i=0; i<s_cols.length; i++)
	{
		for(uint j=0; j<seller_collateral_tokens.length; j++)
		{
			if(s_cols[i].token.addr == seller_collateral_tokens[j])
			{
				//require(s_cols[i].token_amount >= seller_values[j], "INSUF COL");
				s_cols[i].token_amount = s_cols[i].token_amount.sub(seller_values[j]);
			}
		}
	}
	if(seller_collateral_tokens.length > 0)
		userPenaltyMap[order.seller].push(order_id);
	emit NewArbitrationStatus(order_id, status, is_match);
    }
    //是否在支持资产列表里
    function isListed(address token) view internal returns (bool)
    {
	if(tokenMap[token].addr == token)
		return true;
	return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

abstract contract PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    	bool public constant isPriceOracle = true;

    /**
      * @notice Get the price of an asset
      * @param tokenAddress The address to get the price of
      * @return The asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
	function getPrice(address tokenAddress) external virtual view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import './PriceOracle.sol';

contract DotcStorage {


    bool internal is_stop; //设置是否停止

    using SafeMathUpgradeable for uint256;

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    EnumerableSetUpgradeable.AddressSet internal _whitelist;

    /// @notice 支持交易和抵押的资产
    struct Token{
	string symbol;
	address addr;
    }
    Token[] internal allTokens;
    mapping (address => Token) internal tokenMap; //支持资产的Map

    /// @notice 抵押资产结构
    struct Collateral{
	Token token;
	uint256 token_amount;
    }

    /// @notice 卖家的广告，卖家资产按广告质押
    struct Ad{
	address token;		//这里是USDT/USDC/DAI地址
	uint256 ad_id; 		//广告ID
	uint256 token_amount; 	//币数量
	uint256 fiat_price; 	//最低单价
	uint256 low_limit; 	//订单最低限额
	uint256 high_limit; 	//订单最高限额
	uint40 place_time; 	//广告上架时间
	uint8 status; 		//广告状态：1-刚上架，0成交，2-部分成交，3-完全成交, 4-卖家撤单
    }

    /// @notice 订单结构, 买家资产按照订单质押
    struct Order{
	uint256 order_id; 	//订单ID
	uint256 token_amount; 	//币数量
	uint256 price; 		//单价
	address seller;
	address buyer;
	address token;		//这里是USDT/USDC/DAI的地址
	uint40 open_time; 	//订单开始时间
	uint40 close_time; 	//订单结束时间 
	uint40 status; //订单状态：1-买家已锁定，未付款；2-买家已标记付款，订单完成； 3-买家付款超时或者被卖家标记为未付款； 4-交易被买家取消； 5-交易被卖家取消； 6-卖家标记已收款，订单完成 7-仲裁中
	              //71-冻卡、72-少U、73-卡有误、74-少付钱、75-限额、76-超时
    }
    mapping (address => mapping(uint256 => Collateral[])) internal buyerCollateral; 	//买家在每个订单的抵押列表(地址-订单ID-质押数组)
    mapping (address => mapping(uint256 => Collateral[])) internal sellerCollateral; 	//卖家在每个订单的抵押列表（地址-广告ID-质押数组）

    uint256 public total_ad_num; 				//广告数
    mapping (uint256 => Ad) internal adMaps; 			//用户的广告（全局）
    uint256 public total_order_num; 			//订单数
    mapping (uint256 => Order) orderMaps; 		//用户的订单（全局）

    mapping (address => uint256[]) internal userAdsMap; 		//用户发布的订单列表
    mapping (address => uint256[]) internal userOrdersMap; 	//用户相关的订单列表
    mapping (address => uint256[]) internal userPenaltyMap; 	//用户相关的被惩罚订单列表

    mapping (address => uint40) internal frozen_times; 		//用户冻结时间(秒为单位)
    mapping (address => mapping(address => uint256)) internal user_balances; 		//用户资金余额


    uint256 public minAdQuantityMantissa; 		//卖单最小金额 1e18
    uint256 public buyerPenaltyRatioMantissa; 		//买方撤单惩罚*1e18
    uint256 public sellerPenaltyRatioMantissa; 		//卖方撤单惩罚*1e18
    uint256 public buyerCollateralRatioMantissa; 	//买方抵押额度*1e18
    uint256 public sellerCollateralRatioMantissa; 	//卖方抵押额度*1e18
    uint256 public takerFeeRatioMantissa; 		//taker手续费*1e18
    uint256 public makerFeeRatioMantissa; 		//maker手续费*1e18
    uint256 public buyerUnpayPenaltyRationMantissa; 	//买方24h未付款惩罚*1e18
    uint256 public sellerCardRatioMantissa; 		//卖方卡有问题导致买家订单关闭*1e18
    uint256 public buyerFailedArbitrationMantissa; 	//买方申诉失败惩罚*1e18
    uint256 public sellerFailedArbitrationMantissa; 	//卖方申诉失败惩罚*1e18
    uint256 public buyerBlackMoneyPenaltyMantissa; 	//买方黑钱惩罚*1e18
    uint256 public sellerBlackUPenaltyMantissa; 	//卖方黑U惩罚*1e18
    address payable internal fee_wallet;
    address internal customerAdmin;
    PriceOracle internal oracle; 
    ERC20Upgradeable internal usdt;
    ERC20Upgradeable internal usdc;
    ERC20Upgradeable internal dai;

    //事件
    event NewAdOrder(address indexed token, address indexed seller, uint256 order_id, uint256 fiat_price, uint256 low_limit, uint256 high_limit, uint256 dotc_amount, address[] collateral_tokens, uint256[] collateral_dotc_values);
    event NewSellOrder(address indexed token, address indexed seller, uint256 order_id, uint256 price, uint256 amount);
    event NewBuyOrder(address indexed token, address indexed buyer, uint256 order_id, uint256 price, uint256 amount, address[] collateral_tokens, uint256[] collateral_dotc_values);
    event OrderCanceled(address indexed token, address indexed buyer, uint256 order_id, uint256 price, uint256 amount);
    event OrderPaidBuyer(address indexed token, address indexed buyer, uint256 order_id, uint256 price, uint256 amount);
    event OrderUnpaidSeller(address indexed token, address indexed seller, uint256 order_id, uint256 price, uint256 amount);
    event OrderArbitrationBuyer(address indexed token, address indexed buyer, uint256 order_id, uint256 price, uint256 amount, uint40 status, string reason);
    event OrderArbitrationSeller(address indexed token, address indexed seller, uint256 order_id, uint256 price, uint256 amount, uint40 status, string reason);
    event TokenDeposited(address indexed token, address indexed account, uint256 amount);
    event TokenWithdrawn(address indexed token, address indexed account, uint256 amount);
    event NewOracle(address oldOracle, address newOracle);
    event NewTokenAdded(address indexed tokenAddress, string symbol);
    event NewArbitrationStatus(uint256 indexed order_id, uint40 status, bool isMatch);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}