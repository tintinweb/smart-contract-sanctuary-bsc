/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Presale {
    using SafeERC20 for IERC20;
	address private _owner;
	
	IERC20 public BACN;
	IERC20 public BUSD;
    
    //Token by BUSD
	uint256 public priceBUSD;
    //Token by BNB
	uint256 public priceBNB;
    //BNB by BUSD
	uint256 public priceBNBBUSD;
    
	uint256 public minSale;
	uint256 public receiveSale;
	uint256 public endTimeSale;
	uint256 public wdBUSD;
	uint256 public wdBNB;

	uint256 public statusSale;
	
	struct PresaleList {
	    address wallet;
        uint256 amountBUSD;
        uint256 amountBNB;
	}
	mapping(uint256 => PresaleList) private presaleList;
	mapping(address => uint256) private presaleIndex;
	uint256 public presaleTotal;
	
	struct PromoList {
	    address wallet;
        uint256 amountBUSD;
        uint256 amountBNB;
	}
	mapping(uint256 => PromoList) private promoList;
	mapping(address => uint256) private promoIndex;
	uint256 public promoTotal;
	
    constructor() {
        _owner = msg.sender;
        emit OwnerSet(address(0), _owner);
    }
	
    function getSaleInfo(address addr) public view returns (address wallet, uint256 amountBUSD, uint256 amountBNB) {
		PresaleList memory data = presaleList[presaleIndex[addr]];
		return (data.wallet, data.amountBUSD, data.amountBNB);
    }
	
    function getPromoInfo(address addr) public view returns (address wallet, uint256 amountBUSD, uint256 amountBNB) {
		PromoList memory data = promoList[promoIndex[addr]];
		return (data.wallet, data.amountBUSD, data.amountBNB);
    }

    function Config(IERC20 _BACN, IERC20 _BUSD, uint256 _priceBUSD, uint256 _priceBNB, uint256 _priceBNBBUSD, uint256 _minSale, uint256 _endTimeSale, address[] memory promos) public isOwner returns (bool success) {
        require(statusSale == 0, "Config changed only in INACTIVE status");
        BACN = _BACN;
        BUSD = _BUSD;
        require(_priceBUSD > 0, "missing priceBUSD value");
		priceBUSD = _priceBUSD;
        require(_priceBNB > 0, "missing priceBNB value");
		priceBNB = _priceBNB;
        require(_priceBNBBUSD > 0, "missing priceBNBBUSD value");
		priceBNBBUSD = _priceBNBBUSD;
        require(_minSale > 0, "missing minSale value");
        minSale = _minSale;//2700000
        minSale *= (10 ** BUSD.decimals());
        require(_endTimeSale > block.timestamp, "endTimeSale is less them now");
        endTimeSale = _endTimeSale;
        
        //CLEAN
        for (uint256 i = 1; i < promoTotal+1; i++){
            address Paddr = promoList[i].wallet;
            delete promoList[i];
            delete promoIndex[Paddr];
        }
        promoTotal = 0;

        //INSERT
        for (uint256 i = 0; i < promos.length; i++){
            promoTotal++;
            promoIndex[promos[i]] = promoTotal;
            promoList[promoTotal] = PromoList({
				wallet: promos[i],
				amountBUSD: 0,
				amountBNB: 0
			});
        }
        return true;
    }
	
    function setPrice(uint256 _priceBUSD, uint256 _priceBNB, uint256 _priceBNBBUSD) public isOwner returns (bool success){
        require(statusSale == 1, "Price changed only in ACTIVE status");
        require(_priceBUSD > 0, "missing priceBUSD value");
		priceBUSD = _priceBUSD;
        require(_priceBNB > 0, "missing priceBNB value");
		priceBNB = _priceBNB;
        require(_priceBNBBUSD > 0, "missing priceBNBBUSD value");
		priceBNBBUSD = _priceBNBBUSD;
        return true;
    }

    function setStatus(uint256 status) public isOwner returns (bool success){
        if((statusSale == 0 && status == 1) || (statusSale == 1 && status == 2) || (statusSale < 3 && status == 3)){
            if(status == 2){
                //IF SET END STATUS NEED CHECK AVAILABLE BALANCE
                require(receiveSale >= minSale, "Not possible end presale. Balance is less them Minimum");
				require(endTimeSale <= block.timestamp, "Not possible change status. Time for presale not ended");
            }
            if(status == 3){
                //IF SET FROZE STATUS NEED CHECK AVAILABLE BALANCE AND DATETIME
                require(receiveSale < minSale, "Not possible froze presale. Balance is more them Minimum");
				require(endTimeSale <= block.timestamp, "Not possible change status. Time for presale not ended");
            }
            statusSale = status;
        }else{
            require(false, "Missing status");
        }
        return true;
    }

    event TokenSaleBUSD(address receiver, uint256 paid, uint256 received);
	function BuyBUSD(uint256 amount) public returns (bool success){
        require(statusSale == 1 && endTimeSale >= block.timestamp, "Presale not active or time end");
        require(amount > 0, "BuyBUSD: amount is not positive");
        require(priceBUSD > 0, "BuyBUSD: price BUSD not configured");
        uint256 paid = (amount / 100) * priceBUSD;
        if(BACN.decimals() > BUSD.decimals()){
            uint256 diff = BACN.decimals() - BUSD.decimals();
			paid *= (10 ** diff);
        }
        if(BUSD.decimals() > BACN.decimals()){
            uint256 diff = BUSD.decimals() - BACN.decimals();
			paid /= (10 ** diff);
        }
        require(paid > 0, "BuyBUSD: BACN amount for paid is not positive");
		uint256 balance = BACN.balanceOf(address(this));
		require(balance > paid, "BuyBUSD: balance BACN is less then try buy");
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(allowance >= amount, "BuyBUSD: Check the BUSD token allowance");
        require(BUSD.transferFrom(msg.sender, address(this), amount) == true, "BuyBUSD: Couldn't transfer BUSD from buyer");
        require(BACN.transfer(msg.sender, paid) == true, "BuyBUSD: Couldn't transfer BACN to buyer");
		emit TokenSaleBUSD(msg.sender, paid, amount);
        
        //UPDATE
        uint256 UID = presaleIndex[msg.sender];
        if(UID == 0){
            //NOTHINK -> INSERT
            //START FROM 1
            presaleTotal++;
            presaleIndex[msg.sender] = presaleTotal;
            presaleList[presaleTotal] = PresaleList({
                wallet: msg.sender,
                amountBUSD: amount,
                amountBNB: 0
            });
        }else{
            //ALREADY -> UPDATE
            presaleList[UID].amountBUSD += amount;
        }
        //UPDATE PROMO
        require(promoTotal > 0, "BuyBUSD: Nothink added by Promo");
        uint256 promoAmount = ((amount / 100) * 10) / promoTotal;
        require(promoAmount > 0, "BuyBUSD: Amount for promo is less them zero");
        for (uint256 i = 1; i < promoTotal+1; i++){
            promoList[i].amountBUSD += promoAmount;
        }
        receiveSale += amount;
		wdBUSD += (amount / 100) * 90;
        return true;
    }

    event TokenSaleBNB(address receiver, uint256 paid, uint256 received);
	function BuyBNB() payable public {
        require(statusSale == 1 && endTimeSale >= block.timestamp, "Presale not active or time end");
        uint256 amount = msg.value;
        require(amount > 0, "BuyBNB: amount is not positive");
        require(priceBNB > 0, "BuyBNB: price not configured");
        uint256 received = amount * priceBNB;
        if(BACN.decimals() > BUSD.decimals()){
            uint256 diff = BACN.decimals() - BUSD.decimals();
			received *= (10 ** diff);
        }
        if(BUSD.decimals() > BACN.decimals()){
            uint256 diff = BUSD.decimals() - BACN.decimals();
			received /= (10 ** diff);
        }
        require(received > 0, "BuyBNB: received BACN amount is not positive");
		uint256 balance = BACN.balanceOf(address(this));
		require(balance > received, "BuyBNB: balance BACN is less then try buy");
        require(BACN.transfer(msg.sender, received) == true, "BuyBNB: Couldn't transfer BACN to buyer");
        
        //UPDATE
        uint256 UID = presaleIndex[msg.sender];
        if(UID == 0){
            //NOTHINK -> INSERT
            //START FROM 1
            presaleTotal++;
            presaleIndex[msg.sender] = presaleTotal;
            presaleList[presaleTotal] = PresaleList({
                wallet: msg.sender,
                amountBUSD: 0,
                amountBNB: amount
            });
        }else{
            //ALREADY -> UPDATE
            presaleList[UID].amountBNB += amount;
        }
        //UPDATE PROMO
        require(promoTotal > 0, "BuyBNB: Nothink added by Promo");
        uint256 promoAmount = ((amount / 100) * 10) / promoTotal;
        require(promoAmount > 0, "BuyBNB: Amount for promo is less them zero");
        for (uint256 i = 1; i < promoTotal+1; i++){
            promoList[i].amountBNB += promoAmount;
        }
        receiveSale += amount * priceBNBBUSD;
		wdBNB += (amount / 100) * 90;
        emit TokenSaleBNB(msg.sender, amount, received);
    }
	
    function PromoClaim() public returns (bool success) {
        require(statusSale != 0, "Presale inactive");
        require(statusSale != 3, "Presale frozed");
        require(receiveSale >= minSale, "Not possible claim. Balance is less them Minimum");
        //UPDATE
        uint256 UID = promoIndex[msg.sender];
        require(UID > 0, "PromoClaim: Executor not register as Promo");
        //ALREADY -> UPDATE
        if(promoList[UID].amountBUSD > 0 || promoList[UID].amountBNB > 0){
            uint256 amountBUSD = promoList[UID].amountBUSD;
            if(amountBUSD > 0){
                promoList[UID].amountBUSD = 0;
                require(BUSD.transfer(msg.sender, amountBUSD) == true, "PromoClaim: Couldn't transfer BUSD to promo");
            }
            uint256 amountBNB = promoList[UID].amountBNB;
            if(amountBNB > 0){
                promoList[UID].amountBNB = 0;
                address payable to = payable(promoList[UID].wallet);
                to.transfer(amountBNB);
            }
        }else{
            require(false, "PromoClaim: reserved balance is zero");
        }
        return true;
    }

    function MoneyBack() public returns (bool success) {
        require(statusSale == 3, "MoneyBack ready only in FROZE status");
        //UPDATE
        uint256 UID = presaleIndex[msg.sender];
        require(UID > 0, "MoneyBack: Executor not register");
        //ALREADY -> UPDATE
        if(presaleList[UID].amountBUSD > 0 || presaleList[UID].amountBNB > 0){
            uint256 amountBUSD = presaleList[UID].amountBUSD;
            if(amountBUSD > 0){
                presaleList[UID].amountBUSD = 0;
                require(BUSD.transfer(msg.sender, amountBUSD) == true, "MoneyBack: Couldn't transfer BUSD");
            }
            uint256 amountBNB = presaleList[UID].amountBNB;
            if(amountBNB > 0){
                presaleList[UID].amountBNB = 0;
                address payable to = payable(presaleList[UID].wallet);
                to.transfer(amountBNB);
            }
        }else{
            require(false, "MoneyBack: reserved balance is zero");
        }
        return true;
    }

	function EndPresaleERC(IERC20 token_address) public isOwner {
        require(statusSale == 2, "Presale not ended");
		if(token_address == BUSD){
			uint256 balance = BUSD.balanceOf(address(this));
			if(balance >= wdBUSD && wdBUSD > 0){
				BUSD.approve(address(this), wdBUSD);
				require(BUSD.transferFrom(address(this), _owner, wdBUSD) == true, "EndPresaleERC: Couldn't transfer BUSD");
				wdBUSD = 0;
			}else{
				require(false, "EndPresaleERC: balance BUSD is less");
			}
		}else{
			uint256 balance_ = token_address.balanceOf(address(this));
			if(balance_ > 0){
				token_address.approve(address(this), balance_);
				require(token_address.transferFrom(address(this), _owner, balance_) == true, "EndPresaleERC: Couldn't transfer token");
			}else{
				require(false, "EndPresaleERC: balance token is less");
			}
		}
    }
	
	function EndPresaleMain() public isOwner {
        require(statusSale == 2, "Presale not ended");
        address payable to = payable(_owner);
        uint256 balance = address(this).balance;
        if(balance >= wdBNB && wdBNB > 0){
            to.transfer(wdBNB);
			wdBNB = 0;
        }else{
            require(false, "EndPresaleMain: balance BNB is zero");
        }
    }

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    function getOwner() external view returns (address) {
        return _owner;
    }
	
    function setOwner(address newOwner) public isOwner {
		require(newOwner != address(0), "missing new Owner address");
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    modifier isOwner() {
        require(msg.sender == _owner, "Caller is not owner");
        _;
    }
}

pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity ^0.8.7;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }
    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

pragma solidity ^0.8.7;

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "ERC20 operation did not succeed");
        }
    }
}