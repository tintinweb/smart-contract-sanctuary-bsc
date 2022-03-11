/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}



contract dapp_bpm is ReentrancyGuard {

	/**	CONTRACT ADDRESS **/
	address payable owner;
	address payable marketingAddr;
	address payable projectAddr;
	    
	    // calculate token price
	    address tokenAddr;
	    address wbnbAddr;
	    address busdAddr;
    	address payable bnbTokenPool;
    	address payable bnbBUsdPool;



	/**	ERC20 VARS **/
	using SafeERC20 for IERC20;
	IERC20 private BPM;
	IERC20 private WBnb;
	IERC20 private iBusd;



	/**	FEE CONTROL**/
	uint256 parcent_divider = 1000;
	uint256 total_fee = 100;

		// marketing fee + project fee = 1000%
		uint256 marketingFee = 750;
		uint256 projectFee = 250;

    

	/**	WITHDRAW CONTROL **/
	uint256 withdrawCooldown =  24 * 60 * 60; // 24 hours
	uint256 minWithdraw = 5 * 1e18; // 5.000000000
	uint256 maxWhitdraw = 100 * 1e18; // 100.000000000
	uint256 public repSales;



	/**	PANEL CONTROL **/
	uint256 public reproductionPrice = 1*1e9; // 1 token
	uint256 public reproductionPriceStable = 2*1e15; // usd 0.002
	uint256 public artistReproductionPrice = 1*1e15; // usd 0.001
	bool contractPause = false;
	bool contractStablePrice = true;



	/**	SUSCRIPTION **/
	uint256[] plan = [3600, 3600, 3600]; //[1900800, 7603200, 31536000];
	uint256[] planPrice = [60*1e18, 240*1e18, 900*1e18]; //[60*1e18, 240*1e18, 900*1e18];



    /**	USER DATA **/
    struct User {
    	bool isArtist;
    	uint256 total_reproductions;
    	uint256 unpaid_reproductions;
    	uint256 total_withdraw;
    	uint256 lastWithdraw;
    	
    	// suscription
    	bool isSucriptor;
    	uint256 timeStart;
    	uint256 timeEnd;
    	uint256 totalDeposit;
    	uint256 totalWinner;
    }

    mapping(address => User) users;
    mapping(address => bool) register;
    mapping(address => bool) blacklist;

    mapping(address => bool) useContracts;

    // contract event
    event Pausable(bool active, uint256 time);
    event SuscriptionASwitch(bool active, uint256 time);
    event VinculateContract(address indexed _contract, bool active);

    // user event
    event Registared(address indexed wallet, bool is_artist);
    event PaySuscription(address indexed wallet, uint256 Plan);
    event Withdraw(address indexed wallet, uint256 ammount);
    event BlackList(address indexed wallet, bool isBlacklist);

    // address event
    event MarketingAddressChange(address indexed previousOwner, address indexed newOwner);
    event ProjectAddressChange(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**	CONSTRUCTOR DEPLOY **/
	constructor(address payable _owner, address payable _marketing, address payable _project, address _tokenContract, address _wBnb, address _tokenBusd, address payable  _tokenPar, address payable _bnbBusdPar) {
		require(!isContract(_owner));
        owner = _owner;
        marketingAddr = _marketing;
        projectAddr = _project;
        
        tokenAddr = _tokenContract;
	    wbnbAddr = _wBnb;
	    busdAddr = _tokenBusd;

        bnbTokenPool = _tokenPar;
        bnbBUsdPool = _bnbBusdPar;

        BPM = IERC20(_tokenContract);

        WBnb = IERC20(_wBnb);
        iBusd = IERC20(_tokenBusd);
    }



    /***********************************
	*
    *	INTERACTUE
    *
    ************************************/
    function registerUser(bool _isArtist) external onlyBlackListed returns(bool) {
    	require(isContract(msg.sender) == false && isRegister(msg.sender) == false);
    	
    	User storage user = users[msg.sender];
    	user.isArtist = _isArtist;
    	user.lastWithdraw = block.timestamp;

    	register[msg.sender] = true;

    	emit Registared(msg.sender, _isArtist);
        return true;
    }
    

    function withdraw(uint256 _bs, uint256 _rB, uint256 _aB, uint256 _reproductions, uint256 _ammount, uint256 _rd) external nonReentrant pause onlyBlackListed {
    	require(isContract(msg.sender) == false && isRegister(msg.sender) == true);

    	require(_ammount >= minWithdraw && _ammount <= maxWhitdraw || users[msg.sender].isArtist == true);
    	require( (users[msg.sender].lastWithdraw - block.timestamp) >= withdrawCooldown || users[msg.sender].isArtist == true);

    	// Verify the authenticity of the data
    	(uint256 verifyReproduction ,uint256 verfyAmmout) = verifyTrade(_bs, _rB, _aB, _rd);
    	require(verifyReproduction == _reproductions && verfyAmmout == _ammount);

    	// Calculate the ammount of reproductions to charge
    	uint256 repUsed = ammountReproductions(_ammount);
    	require(repUsed <= (_reproductions + users[msg.sender].unpaid_reproductions)  || users[msg.sender].isArtist == true && repUsed <= repSales);

    	// Verify playback times
    	uint256 timeRep = reproductionTime(repUsed);
    	require( (users[msg.sender].lastWithdraw - block.timestamp) >= timeRep  || users[msg.sender].isArtist == true);

  
    	User storage user = users[msg.sender];
    	
    	uint256 payRep;
        uint256 timeRest;


    	// calculate max reproductions used
    	if(repUsed < (_reproductions + user.unpaid_reproductions) ){
    		payRep = repUsed;
    		user.unpaid_reproductions += _reproductions - repUsed;
            timeRest = block.timestamp - reproductionTime(_reproductions - repUsed);

    	}else{
    		payRep = (_reproductions + user.unpaid_reproductions);
    		user.unpaid_reproductions = 0;
            timeRest = block.timestamp;
    	}

    	// calculate token value in usd
    	uint256 payWithdraw = reproductionValue(payRep);
    	uint256 repUsdInBnb = payWithdraw / get_bnbPrice();
    	(uint256 tokenInBnb,) = get_tokenBnbPrice();
    	uint256 totalTokenPay;

    	if(contractStablePrice){
       		totalTokenPay = repUsdInBnb / tokenInBnb;
    	}else{
    		totalTokenPay = payWithdraw;
    	}

    	// calculate fees
    	uint256 fees = payFees(totalTokenPay);
    	uint256 totalPay = totalTokenPay - fees;

    	// save data
    	user.total_reproductions += payRep;
    	user.total_withdraw += totalTokenPay;
    	user.lastWithdraw = timeRest;

    	if(!user.isArtist){
    		repSales += payRep;
    	}

    	// verifi suscription time
    	if(timeSuscription(msg.sender)){
    		stopSuscription(msg.sender);
    	}

    	BPM.safeTransfer(msg.sender, totalPay);

    	emit Withdraw(msg.sender, totalTokenPay);
    }


    function payPremium(uint256 _plan) external pause onlyBlackListed {
    	require(isRegister(msg.sender));

    	(uint256 tokenInBnb,) = get_tokenBnbPrice();
    	uint256 usdInBnb = planPrice[_plan] / get_bnbPrice();
    	uint256 totalPay = usdInBnb / tokenInBnb;

    	BPM.safeTransferFrom(msg.sender, address(this), totalPay);
    	payFees(totalPay);

    	User storage user = users[msg.sender];

    	user.timeStart = block.timestamp;
    	user.timeEnd += plan[_plan];
    	user.totalDeposit += totalPay;    	
    	user.isSucriptor = true;

    	emit PaySuscription(msg.sender, _plan );
    }



    /***********************************
	*
    *	VINCULATE CONTRACT FUNCTIONS
    *
    ************************************/
    function contractWithdraw(address _user, uint256 _ammount) external pause projectContract {
    	require(_user != address(0) && isContract(_user) == false && isRegister(_user) == true && isBlackListed(_user) == false);
    	require(_ammount >= minWithdraw && _ammount <= maxWhitdraw || users[_user].isArtist == true &&  _ammount < (contractBalance()*10/100) );
    	
    	payFees(_ammount);
    	BPM.transfer(_user, _ammount);
    }

    function set_userTotalWithdraw(address _user, uint256 _value) external pause projectContract {
    	require(isContract(_user) == false && isRegister(_user) == true && isBlackListed(_user) == false);

    	User storage user = users[_user];
    	user.total_withdraw = _value;
    }

    function set_userLastWithdraw(address _user, uint256 _value) external pause projectContract {
    	require(isContract(_user) == false && isRegister(_user) == true && isBlackListed(_user) == false);

    	User storage user = users[_user];
    	user.lastWithdraw = _value;
    }

    /**
	*	SUSCRIPTION	
    **/
    function set_userTotalWinner(address _user, uint256 _value) external pause projectContract {
    	require(isContract(_user) == false && isRegister(_user) == true && isBlackListed(_user) == false);

    	User storage user = users[_user];
    	user.totalWinner = _value;
    }	

    function set_stopSuscription(address _user) external pause projectContract {
    	require(isContract(_user) == false && isRegister(_user) == true && users[_user].isSucriptor == true);
    	stopSuscription(_user);
    }



    /***********************************
	*
    *	GET DATA
    *
    ************************************/
    function contractBalance() public view returns(uint256){
    	return BPM.balanceOf(address(this));
    }

    function get_tokenBnbPrice() public view returns(uint256 _tokenDecimal, uint256 _tokenPrice){
    	return (WBnb.balanceOf(bnbTokenPool) / BPM.balanceOf(bnbTokenPool), (WBnb.balanceOf(bnbTokenPool) / BPM.balanceOf(bnbTokenPool))*1e9 ) ;
    }

    function get_bnbPrice() public view returns(uint256){
    	return (iBusd.balanceOf(bnbBUsdPool) / WBnb.balanceOf(bnbBUsdPool));
    } 

    function isBlackListed(address _address) public view returns(bool) {
    	return blacklist[_address];
    }

    function isRegister(address _address) public view returns(bool) {
    	return register[_address];
    }

    function timeSuscription(address _addr) public view returns(bool){
        if(!users[_addr].isSucriptor){
            return false;
        }
    	
        if(users[_addr].timeStart - block.timestamp >= users[_addr].timeEnd){
            return true;
        }else{
            return false;
        }
    }

    function get_contractWallets() external view returns(address _owner, address _marketing, address _project) {
    	return (owner, marketingAddr, projectAddr);
    }
    
    function get_dataUser(address _addr) external view returns(uint256 _total_reproductions, uint256 _unpaid_reproductions, uint256 _total_withdraw, uint256 _lastWhithdraw) {
    	return (users[_addr].total_reproductions, 
    			users[_addr].unpaid_reproductions,
    			users[_addr].total_withdraw,
    			users[_addr].lastWithdraw);
    }

    function get_suscriptionInfo(address _addr) external view returns(bool _isSuscriptor, uint256 _startSuscription, uint256 _endSuscription){
    	return (users[_addr].isSucriptor, 
    			users[_addr].timeStart, 
    			users[_addr].timeEnd);
    }

    function get_feeConfig() external view returns(uint256 _DIVIDER, uint256 _totalFee, uint256 _marketingFEE, uint256 _projectFee) {
    	return (parcent_divider, 
    			total_fee, 
    			marketingFee, 
    			projectFee);
    }

    function get_withdrawConfig() external view returns(uint256 _cooldown, uint256 _min_withdraw, uint256 _max_withdraw) {
    	return (withdrawCooldown,
    			minWithdraw,
    			maxWhitdraw);
    }

    function get_priceConfig() external view returns(bool _active, address _wBnb, address _busd, address payable _wBnbBusdPool, address payable _wBnbTokenPool) {
    	return (contractStablePrice, wbnbAddr, busdAddr, bnbBUsdPool, bnbTokenPool);
    }

    function get_viculateContract(address _contract) external view returns(bool) {
    	return useContracts[_contract];
    }

    function get_planInfo() external view returns(uint256 _plan1, uint256 _price1, uint256 _plan2, uint256 _price2, uint256 _plan3, uint256 _price3) {
    	return (plan[0], planPrice[0], plan[1], planPrice[1], plan[2], planPrice[2]);
    }


    /***********************************
	*
    *	SET DATA
    *
    ************************************/
    function transfer_ownership(address payable _new, bool _confirm) external onlyOwner {
    	require(_new != address(0) && _confirm == true);
    	address _old = owner;
    	owner = _new;

    	emit OwnershipTransferred(_old, _new);
    }

    function set_feeConfig(uint256 _DIVIDER, uint256 _totalFee, uint256 _marketingFEE, uint256 _projectFee) external onlyOwner {
    	require(_DIVIDER >= 100 && total_fee > 0 && total_fee <= _DIVIDER/2, "undivisible value");
    	require(_marketingFEE > 0 && _projectFee > 0, "undivisible value");
    	require(_marketingFEE + _projectFee == _DIVIDER, "undivisible value");

    	parcent_divider = _DIVIDER;
    	total_fee = _totalFee;
    	marketingFee = _marketingFEE;
    	projectFee = _projectFee;
    }

    function set_withdrawConfig(uint256 _cooldown, uint256 _min_withdraw, uint256 _max_withdraw) external onlyOwner {
    	require(_cooldown < 34);
    	withdrawCooldown = _cooldown * 60 * 60;
    	minWithdraw = _min_withdraw;
    	maxWhitdraw = _max_withdraw;
    }

    function set_marketing_address(address payable _new) external onlyOwner {
    	require(_new != address(0));
    	address _old = marketingAddr;
    	marketingAddr = _new;

    	emit MarketingAddressChange(_old, _new);
    }

    function set_project_address(address payable _new) external onlyOwner {
    	require(_new != address(0));
    	address _old = projectAddr;
    	projectAddr = _new;

    	emit ProjectAddressChange(_old, _new);
    }

	function set_blacklist(address _address, bool _state) external onlyOwner {
    	blacklist[_address] = _state;
    	emit BlackList(_address, _state);
	}

	function set_contractPause(bool _switch) external onlyOwner {
		contractPause = _switch;
		emit Pausable(_switch, block.timestamp);
	}

	function switchPriceStable(bool _switch) external onlyOwner {
		contractStablePrice = _switch;
	}

	function set_stableConfig(address _wBnb, address _Busd, address payable _wBnbBusdPool, address payable _wBnbTokenPool) external onlyOwner {
		wbnbAddr = _wBnb;
		busdAddr = _Busd;
		bnbBUsdPool = _wBnbBusdPool;
		bnbTokenPool = _wBnbTokenPool;

		WBnb = IERC20(_wBnb);
        iBusd = IERC20(_Busd);
	}

	function set_reproductionPrice(uint256 _normal, uint256 _stable) external onlyOwner {
		require(_normal > 0 && _stable > 0);

		reproductionPrice = _normal;
		reproductionPriceStable = _stable;
	}

	function set_artistRepPrice(uint256 _value) external onlyOwner {
		require(_value > 0);
		artistReproductionPrice = _value;
	}

    function set_viculateContract(address _contract, bool _active) external onlyOwner {
    	useContracts[_contract] = _active;
    	emit VinculateContract(_contract, _active);
    }

    function set_planTimes(uint256 _hours1, uint256 _hours2, uint256 _hours3) external onlyOwner {
    	plan[0] = _hours1 * 60 * 60;
    	plan[1] = _hours2 * 60 * 60;
    	plan[2] = _hours3 * 60 * 60;
    }

	function set_planPrices(uint256 _usd1, uint256 _usd2, uint256 _usd3) external onlyOwner {
    	planPrice[0] = _usd1;
    	planPrice[1] = _usd2;
    	planPrice[2] = _usd3;
    }



    /***********************************
	*
    *	INTERNAL AND PRIVATE FUNCTION
    *
    ************************************/
    function isContract(address account) private view returns (bool) {
        return account.code.length > 0;
    }

    function ammountReproductions(uint256 _ammount) private view returns(uint256){
    	return (_ammount / getReproductionPrice());
    }

    function reproductionValue(uint256 _rep) private view returns(uint256){
    	uint256 _repValue;

    	if(users[msg.sender].isArtist == true){
    		_repValue = _rep * artistReproductionPrice;
    	}else{
    		_repValue = _rep * getReproductionPrice();
    	}

    	return _repValue;
    }

    function reproductionTime(uint256 _rep) private pure returns(uint256){
    	return (_rep * 10); //return (_rep * 180);
    }

    function calculatePrice(uint256 _base, uint256 _ammount, uint256 _incognit) private pure returns(uint256){
    	return ( _ammount * _incognit / _base);
    }

    function getReproductionPrice() private view returns(uint256){
    	uint256 _price;
    	if(contractStablePrice){
    		_price = reproductionPriceStable;
    	}else{
    		_price = reproductionPrice;
    	}

    	return _price;
    }
    
    function verifyTrade(uint256 _b, uint256 _rpB, uint256 _aB, uint256 _ramdom) private pure returns(uint256 _rpT, uint256 _aT){
    	uint256 rpMB;
    	rpMB = _rpB * _ramdom;
        uint256 aMB;
		aMB = (_b*1e18) * (_ramdom*1e18);
        uint256 rpT;
		rpT = rpMB / _b;
        uint256 aT;
		aT = aMB / (_aB*1e18);

		return (rpT, aT);
    }
    
     function payFees(uint256 _ammount) private returns(uint256){
     	uint256 fee = _ammount * total_fee / parcent_divider;
     	uint256 mkt = fee * marketingFee / parcent_divider;
        uint256 prj = fee * projectFee / parcent_divider;
            
        BPM.safeTransfer(marketingAddr, mkt);
        BPM.safeTransfer(projectAddr, prj);
            
        return prj+mkt;
    }

    function stopSuscription(address _addr) private{

    	User storage user = users[_addr];

    	user.isSucriptor = false;
    	user.timeStart = 0;
    	user.timeEnd = 0;
    }
    
    

    /***********************************
	*
    *	MODIFIER's 
    *
    ************************************/
    modifier onlyOwner() {
            require(owner == msg.sender, "Ownable: caller is not the owner");
            _;
	}

	modifier onlyBlackListed() {
            require(!isBlackListed(msg.sender));
            _;
        }

	modifier pause() {
            require(contractPause == false);
            _;
	}

	modifier projectContract() {
            require(useContracts[msg.sender] == true);
            _;
	}
}



interface IERC20 {
   
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

/***
	TESTNET

token
0x8Da76AeF7fA5f79985eCcc1500b6A39476552F2f

wrapped bnb
0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd 

busd
0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7

par wbnb/token
0xaeec8C3158dcC65ddE7f8f82C21Bc68e3EAD37dd

pool busd/bnb
0xe0e92035077c39594793e61802a350347c320cf2
***/