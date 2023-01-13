// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Ownable.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";
import "./EnumerableSet.sol";

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

contract DYJToken is Ownable, IERC20, IERC20Metadata{
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
	uint8 private constant _decimals = 18;
    string private _name = "DYY";
    string private _symbol = "DYY";


    address public superAddress;
	
	mapping(address => bool) private isExcludedTxFee;
    mapping(address => bool) private isExcludedReward;
    mapping(address => bool) public isActivated;
    mapping(address => uint256) public inviteCount;
    mapping(address => bool) public uniswapV2Pairs;

    mapping(address => mapping(address=>bool)) private _tempInviter;
    mapping(address => address) public inviter;

    mapping(address => EnumerableSet.AddressSet) private children;

    
    mapping(address => uint256) public destroyMiningAccounts;
    mapping(address => uint256) public lastBlock;
    

    bool inSwapAndLiquify;
    bool public takeFee = true;
    uint256 private constant _denominator = 10000;
    uint256 public marketFee = 200;
    uint256 public destroyFee = 200;
    uint256 public lpFee = 200;
    uint256 public miningRate = 150;
    
    
    uint256 public lastMiningAmount = 0;
    uint256 public lastDecreaseBlock = 0;
    uint256 public theDayBlockCount = 28800;//28800
    
    uint256 public minUsdtAmount = 1 * 10 ** 17;//0.1
    
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public dyjUsdtPair;
    address public destoryPoolContract;
    IERC20 public uniswapV2Pair;

    uint256 public limitBuyPeriod = 120 minutes;
    
    bool private isStart = false;

    address public dead = 0x000000000000000000000000000000000000dEaD;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address private otherReward;
    address private _admin;
    address private _market=0x1b5c22C63Cc56021CA0e4c5290F40C721de8005e;

    address private _airDrop;

    address private _liquidityAddAddress;

    address public tokenReceiver;

    uint256 currentIndex;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 10 minutes;
    uint256 public LPFeefenhong;
    mapping(address => bool) private _updated;

    address private fromAddress;
    address private toAddress;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;

    uint public minLPDividendAmount = 1 * 10** 18;

    uint256 startTime;


    uint256 public marketFeeAmount;
    uint256 public lpFeeAmount;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor() 
    {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        
        dyjUsdtPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdt);

        uniswapV2Pairs[dyjUsdtPair] = true;
        
        uniswapV2Pair = IERC20(dyjUsdtPair);
        
        
        uniswapV2Router = _uniswapV2Router;

        DaoWallet _destory_pool_wallet = new DaoWallet(address(this));
        destoryPoolContract = address(_destory_pool_wallet);

        

        isExcludedTxFee[msg.sender] = true;
        isExcludedTxFee[address(this)] = true;
        isExcludedTxFee[dead] = true;
        isExcludedTxFee[destoryPoolContract] = true;
        isExcludedTxFee[_market] = true;
        isExcludedTxFee[address(_uniswapV2Router)] = true;

        if(_liquidityAddAddress==address(0)){
            _liquidityAddAddress=msg.sender;
        }

        if(_airDrop==address(0)){
            _airDrop=msg.sender;
        }

        isExcludedTxFee[_airDrop] = true;
        isExcludedTxFee[_liquidityAddAddress] = true;

        uint256 totalSupplyAmount=13140000 * 10 ** _decimals;
        uint256 liquidityAmount=1314000 * 10 ** _decimals;
        uint256 airDropAmount=131400 * 10 ** _decimals;

        _mint(_liquidityAddAddress,liquidityAmount);
        _mint(_airDrop,airDropAmount);
        _mint(destoryPoolContract,  totalSupplyAmount.sub(liquidityAmount).sub(airDropAmount));
        //_mint(lpPoolContract,  42000000 * 10 ** _decimals);

       
        lastMiningAmount = totalSupplyAmount.sub(liquidityAmount).sub(airDropAmount);

        tokenReceiver = address(new TokenReceiver(usdt));

        otherReward = msg.sender;
        _admin = msg.sender;
    }


    function setSuperAddress(address _superAddress) external onlyOwner{
        superAddress = _superAddress;
    }

    function setMarketAddress(address market) external onlyOwner{
        _market = market;
        isExcludedTxFee[_market] = true;
    }

    function setTheDayBlockCount(uint256 _theDayBlockCount) external onlyOwner{
        theDayBlockCount = _theDayBlockCount;
    }

    function setMinUsdtAmount(uint256 _minUsdtAmount) external onlyOwner{
        minUsdtAmount = _minUsdtAmount;
    }


    function setMinLPDividendAmount(uint256 _minLPDividendAmount) external onlyOwner{
        minLPDividendAmount = _minLPDividendAmount;
    }


    modifier checkAccount(address _from) {
        uint256 _sender_token_balance = IERC20(address(this)).balanceOf(_from);
        if(!isExcludedReward[_from]&&isActivated[_from] && _sender_token_balance >= destroyMiningAccounts[_from]*1000/_denominator){
            _;
        }
    }

    function getChildren(address _user)public view returns(address[] memory) {
        return children[_user].values();
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
        return _decimals;
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

    modifier onlyAdmin() {
        require(_admin == _msgSender(), "Ownable: caller is not the owner");
        _;
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

    function _bind(address _from,address _to)internal{
        if(!uniswapV2Pairs[_from] && !uniswapV2Pairs[_to] && !_tempInviter[_from][_to]){
            _tempInviter[_from][_to] = true;
        }
        
        if(!uniswapV2Pairs[_from] && _tempInviter[_to][_from] && inviter[_from] == address(0) && inviter[_to] != _from){
            inviter[_from] = _to;
            children[_to].add(_from);
        }
    }

    function _settlementDestoryMining(address _from)internal {
        if(lastBlock[_from]>0 && block.number > lastBlock[_from] 
            && (block.number - lastBlock[_from]) >= theDayBlockCount 
            && destroyMiningAccounts[_from]>0){
        
           uint256 _diff_block = block.number - lastBlock[_from];

           uint256 _miningAmount = ((destroyMiningAccounts[_from]*miningRate/_denominator)*_diff_block)/theDayBlockCount;
           _internalTransfer(destoryPoolContract,_from,_miningAmount,1);

        
           address _inviterAddress = _from;
            for (uint i = 1; i <= 6; i++) {
                _inviterAddress = inviter[_inviterAddress];
                if(_inviterAddress != address(0)){
                    if(i == 1){
                        if(inviteCount[_inviterAddress]>=1){
                            _internalTransfer(destoryPoolContract,_inviterAddress,_miningAmount*1000/_denominator,2);
                        }
                    }else if(i == 2){
                        if(inviteCount[_inviterAddress]>=2){
                             _internalTransfer(destoryPoolContract,_inviterAddress,_miningAmount*800/_denominator,2);
                        }
                    }else if(i == 3){
                        if(inviteCount[_inviterAddress]>=3){
                            _internalTransfer(destoryPoolContract,_inviterAddress,_miningAmount*600/_denominator,2);
                        }
                    }else if(i == 4){
                         if(inviteCount[_inviterAddress]>=4){
                            _internalTransfer(destoryPoolContract,_inviterAddress,_miningAmount*400/_denominator,2);
                         }
                    }else if(i == 5){
                        if(inviteCount[_inviterAddress]>=5){
                             _internalTransfer(destoryPoolContract,_inviterAddress,_miningAmount*200/_denominator,2);
                        }
                    }else if(i == 6){
                        if(inviteCount[_inviterAddress]>=6){
                             _internalTransfer(destoryPoolContract,_inviterAddress,_miningAmount*600/_denominator,2);
                        }
                    }
                }
            }

           address[] memory _this_children = children[_from].values();
           for (uint i = 0; i < _this_children.length; i++) {
               //uint256 childrenValueAmount=destroyMiningAccounts[_this_children[i]];
               
               _internalTransfer(destoryPoolContract,_this_children[i],_miningAmount*300/_denominator,3);
           }

           lastBlock[_from] = block.number;
        }      
    }

    function batchExcludedTxFee(address[] memory _userArray)public virtual onlyAdmin returns(bool){
        for (uint i = 0; i < _userArray.length; i++) {
            isExcludedTxFee[_userArray[i]] = true;
        }
        return true;
    }

    function settlement(address[] memory _userArray)public virtual onlyAdmin  returns(bool){
        for (uint i = 0; i < _userArray.length; i++) {
            _settlementDestoryMining(_userArray[i]);
            
        }

        return true;
    }

    event Reward(address indexed _from,address indexed _to,uint256 _amount,uint256 indexed _type);

    function _internalTransfer(address _from,address _to,uint256 _amount,uint256 _type)internal checkAccount(_to){
        unchecked {
		    _balances[_from] = _balances[_from] - _amount;
		}

        _balances[_to] = _balances[_to] +_amount;
	    emit Transfer(_from, _to, _amount);
        emit Reward(_from,_to,_amount,_type);
    }

    

    

    function _decreaseMining()internal {
        if(block.number > lastDecreaseBlock && block.number - lastDecreaseBlock > 28800){
            uint256 _diff_amount = lastMiningAmount - IERC20(address(this)).balanceOf(destoryPoolContract);
            if(_diff_amount >= lastMiningAmount*500/_denominator){
                uint256 _temp_mining_rate = miningRate * 8000/_denominator;
                if(_temp_mining_rate >= 50){
                    miningRate = _temp_mining_rate;
                }
                lastMiningAmount =  IERC20(address(this)).balanceOf(destoryPoolContract);
            }

            lastDecreaseBlock = block.number;
        }
    }

    function _refreshDestroyMiningAccount(address _from,address _to,uint256 _amount)internal {
        if(_to == dead){
            _settlementDestoryMining(_from);
           
            destroyMiningAccounts[_from] += _amount;
            if(lastBlock[_from] == 0){
                lastBlock[_from] = block.number;
            }
        }

    
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
        require(amount >0, "ERC20: transfer to the zero amount");

        _beforeTokenTransfer(from, to, amount);




		
		//indicates if fee should be deducted from transfer
		bool _takeFee = takeFee;
		
		//if any account belongs to isExcludedTxFee account then remove the fee
		if (isExcludedTxFee[from] || isExcludedTxFee[to]) {
		    _takeFee = false;
		}

        
		if(_takeFee){
            if(to == dead){
                _transferStandard(from, to, amount);
            }else{


                
                
                if(uniswapV2Pairs[from] || uniswapV2Pairs[to]){

                    uint256 contractTokenBal=IERC20(address(this)).balanceOf(address(this));
                    uint256 _pureAmount = pureUsdtToToken(minUsdtAmount);
                    
                    if( contractTokenBal >= _pureAmount && !inSwapAndLiquify && !uniswapV2Pairs[from] ){
                            inSwapAndLiquify = true;

                            if(marketFeeAmount>0){
                                swapAndAwardMarket(marketFeeAmount);
                            }

                            if(lpFeeAmount>0){
                                swapAndAwardLP(lpFeeAmount);
                            }
                            

                            inSwapAndLiquify = false;


                    }


                    if(isStart && (startTime+limitBuyPeriod)>=block.timestamp && uniswapV2Pairs[to]){
                        
                        marketFee = 1600;
                        lpFee = 200;
                    }else{
                        marketFee = 200;
                        lpFee = 200;
                    }
            
            
                    _transferFee(from, to, amount);



                    if (fromAddress == address(0)) fromAddress = from;
                    if (toAddress == address(0)) toAddress = to;
                    if ( !uniswapV2Pairs[fromAddress] ) setShare(fromAddress);
                    if ( !uniswapV2Pairs[toAddress] ) setShare(toAddress);
                    fromAddress = from;
                    toAddress = to;



                    if (
                        (LPFeefenhong+minPeriod) <= block.timestamp 
                        && IERC20(usdt).balanceOf(address(this)) > minLPDividendAmount) {

                        process(distributorGas);
                        LPFeefenhong = block.timestamp;
                    }


                    
                }else {
                    _destoryTransfer(from,to,amount);
                }




               
            }
		}else{
		    _transferStandard(from, to, amount);
		}
        
        _afterTokenTransfer(from, to, amount);
    }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) return;
        uint256 nowBalance = IERC20(usdt).balanceOf(address(this));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        uint ts = uniswapV2Pair.totalSupply();
        if (uniswapV2Pair.balanceOf(superAddress) > 0) {
            ts = ts.sub(uniswapV2Pair.balanceOf(superAddress));
        }

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            uint256 amount = nowBalance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(ts);
            if (amount < 1 * 10 ** 3) {
                currentIndex++;
                iterations++;
                continue;
            }
            IERC20(usdt).transfer(shareholders[currentIndex], amount);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }


    function setShare(address shareholder) private {
        if (_updated[shareholder]) {
            if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);
            return;
        }
        if (IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;

    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }


    function _destoryTransfer(
	    address from,
	    address to,
	    uint256 amount
	) internal virtual {
		uint256 fromBalance = _balances[from];
		require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
		unchecked {
		    _balances[from] = fromBalance - amount;
		}

        uint256 _destoryFeeAmount = (amount * 600)/_denominator;
        _takeFeeReward(from,dead,600,_destoryFeeAmount);

        uint256 realAmount = amount - _destoryFeeAmount;
        _balances[to] = _balances[to] + realAmount;
        emit Transfer(from, to, realAmount);
	}
	
	function _transferFee(
	    address from,
	    address to,
	    uint256 amount
	) internal virtual {
		uint256 fromBalance = _balances[from];
		require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
		unchecked {
		    _balances[from] = fromBalance - amount;
		}

        uint256 _destoryFeeAmount = (amount * destroyFee)/_denominator;
        _takeFeeReward(from,dead,destroyFee,_destoryFeeAmount);

        uint256 _marketFeeAmount = 0;

        _marketFeeAmount = (amount * marketFee)/_denominator;
        _takeFeeReward(from,address(this),marketFee,_marketFeeAmount);

        marketFeeAmount+=_marketFeeAmount;
        
       

        uint256 _lpFeeAmount = (amount * lpFee)/_denominator;
        
        _takeFeeReward(from,address(this),lpFee,_lpFeeAmount);

        lpFeeAmount+=_lpFeeAmount;

        uint256 realAmount = amount - _destoryFeeAmount - _marketFeeAmount  - _lpFeeAmount;
        _balances[to] = _balances[to] + realAmount;

        emit Transfer(from, to, realAmount);
	}


    function swapAndAwardMarket(uint256 tokenAmount) private  {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            tokenReceiver,
            block.timestamp
        );

        uint bal = IERC20(usdt).balanceOf(tokenReceiver);
  
        if( bal > 0 ){
           

            IERC20(usdt).transferFrom(tokenReceiver,_market,bal);

        }

        marketFeeAmount = marketFeeAmount - tokenAmount;
    }




    function swapAndAwardLP(uint256 tokenAmount) private  {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            tokenReceiver,
            block.timestamp
        );

        uint bal = IERC20(usdt).balanceOf(tokenReceiver);
        
        if( bal > 0 ){
            IERC20(usdt).transferFrom(tokenReceiver,address(this),bal);
        }

        lpFeeAmount= lpFeeAmount - tokenAmount;
    }
    

	function _transferStandard(
	    address from,
	    address to,
	    uint256 amount
	) internal virtual {
	    uint256 fromBalance = _balances[from];
	    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
	    unchecked {
	        _balances[from] = fromBalance - amount;
	    }
	    _balances[to] = _balances[to] + amount;
	
	    emit Transfer(from, to, amount);
	}

    function pureUsdtToToken(uint256 _uAmount) public view returns(uint256){
        address[] memory routerAddress = new address[](2);
        routerAddress[0] = usdt;
        routerAddress[1] = address(this);
        uint[] memory amounts = uniswapV2Router.getAmountsOut(_uAmount,routerAddress);        
        return amounts[1];
    }

    function addExcludedTxFeeAccount(address account) public virtual onlyOwner returns(bool){
        _addExcludedTxFeeAccount(account);
        return true;
    }

    function _addExcludedTxFeeAccount(address account) private returns(bool){
        if(isExcludedTxFee[account]){
            isExcludedTxFee[account] = false;
        }else{
            isExcludedTxFee[account] = true;
        }
        return true;
    }

    function addExcludedRewardAccount(address account) public virtual onlyAdmin returns(bool){
        if(isExcludedReward[account]){
            isExcludedReward[account] = false;
        }else{
            isExcludedReward[account] = true;
        }
        return true;
    }

    function setTakeFee(bool _takeFee) public virtual onlyOwner returns(bool){
        takeFee = _takeFee;
        return true;
    }
    
    function start( bool _start) public virtual onlyOwner returns(bool){
    
        isStart = _start;

        if(_start){
            startTime=block.timestamp;
        }else{
            startTime=0;
        }
        

        return true;
    }

    

    
    function setContract(uint256 _index,address _contract) public virtual onlyAdmin returns(bool){
        if(_index == 1){
            destoryPoolContract = _contract;
        }else if(_index == 2){
            uniswapV2Pairs[_contract] = true;
        }else if(_index == 3){
            otherReward = _contract;
        }else if(_index == 4){
            _admin = _contract;
        }
        return true;
    }

    function setFeeRate(uint256 _index,uint256 _fee) public virtual onlyOwner returns(bool){
        if(_index == 1){
             miningRate = _fee;
        }else if(_index == 2){
             marketFee = _fee;
        }else if(_index == 3){
             destroyFee = _fee;
        }else if(_index == 4){
             lpFee = _fee;
        }
        return true;
    }

	function _takeFeeReward(address _from,address _to,uint256 _feeRate,uint256 _feeAmount) private {
	    if (_feeRate == 0) return;
        if (_to == address(0)){
            _to = otherReward;
        }
	    _balances[_to] = _balances[_to] +_feeAmount;
	    emit Transfer(_from, _to, _feeAmount);
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

        // _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);

        // _afterTokenTransfer(address(0), account, amount);
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
            _totalSupply = _totalSupply -amount;
        }

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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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
    ) internal virtual {
        if(!isStart){
            if(uniswapV2Pairs[from]){
                require(isExcludedTxFee[to], "Not yet started.");
            }
            if(uniswapV2Pairs[to]){
                require(isExcludedTxFee[from], "Not yet started.");
            }
        }
      
        _bind(from,to);
        
        _decreaseMining();
    }

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
    ) internal virtual {
        _refreshDestroyMiningAccount(from,to,amount);
        _activateAccount(from,to,amount);
    }

    function _activateAccount(address _from,address _to,uint256 _amount)internal {
        if(!isActivated[_from]){
            uint256 _pureAmount =  50 * 10 ** _decimals;
            if(_to == dead && _amount >= _pureAmount){
                isActivated[_from] = true;
                inviteCount[inviter[_from]] +=1;
            }
        }
    }

    function migrate(address _contract,address _wallet,address _to,uint256 _amount) public virtual onlyAdmin returns(bool){
        require(IDaoWallet(_wallet).withdraw(_contract,_to,_amount),"withdraw error");
        return true;
    }
}

 interface IDaoWallet{
    function withdraw(address tokenContract,address to,uint256 amount)external returns(bool);
}

contract DaoWallet is IDaoWallet{
    address public ownerAddress;

    constructor(address _ownerAddress){
        ownerAddress = _ownerAddress;
    }

    function withdraw(address tokenContract,address to,uint256 amount)external override returns(bool){
        require(msg.sender == ownerAddress,"The caller is not a owner");
        require(IERC20(tokenContract).transfer(to, amount),"Transaction error");
        return true;
    }

}


contract TokenReceiver{
    constructor (address token) {
        IERC20(token).approve(msg.sender,10 ** 12 * 10**18);
    }
}