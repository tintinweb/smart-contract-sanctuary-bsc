/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

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

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface Token {
    function transferFrom(address, address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
}

contract _ERC20 is Context, IERC20 { 
    using SafeMath for uint256;
    //using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    function _constructor(string memory name, string memory symbol) internal {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }  //overriden in Defiat_Token

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
} 

contract DeFiat_Points is _ERC20{
    
    //global variables
    address public deFiat_Token;                        //1 DeFiat token address 
    mapping(address => bool) public deFiat_Gov;         //multiple governing addresses
    
    uint256 public txThreshold; //min tansfer to generate points
    mapping (uint => uint256) public _discountTranches;
    mapping (address => uint256) private _discounts; //current discount (base100)


    modifier onlyGovernors {
        require(deFiat_Gov[msg.sender] == true, "Only governing contract");
        _;
    }
    modifier onlyToken {
        require(msg.sender == deFiat_Token, "Only token");
        _;
    }
    
    constructor() { //token and governing contract
        deFiat_Gov[msg.sender] = true; //msg.sender is the 1st governor
        _constructor("DeFiat Points", "DFTP"); //calls the ERC20 "_constructor" to update token name
        txThreshold = 1e18*100;//
        setAll10DiscountTranches(
             1e18*10,  1e18*50,  1e18*100,  1e18*500,  1e18*1000, 
             1e18*1e10,  1e18*1e10+1,  1e18*1e10+2, 1e18*1e10+3); //60% and abovse closed at launch.
        _discounts[msg.sender]=100;
        //no minting. _totalSupply = 0
    }

    function viewDiscountOf(address _address) public view returns (uint256) {
        return _discounts[_address];
    }
    function viewEligibilityOf(address _address) public view returns (uint256 tranche) {
        uint256 _tranche = 0;
        for(uint256 i=0; i<=9; i++){
           if(balanceOf(_address) >= _discountTranches[i]) { 
             _tranche = i;}
           else{break;}
        }
        return _tranche;
    }
    function discountPointsNeeded(uint _tranche) public view returns (uint256 pointsNeeded) {
        return( _discountTranches[_tranche]); //check the nb of points needed to access discount tranche
    }

    function updateMyDiscountOf() public returns (bool) {
        uint256 _tranche = viewEligibilityOf(msg.sender);
        _discounts[msg.sender] =  SafeMath.mul(10, _tranche); //update of discount base100
        return true;
    }  //users execute this function to upgrade a status level to the max tranche

    function setDeFiatToken(address _token) external onlyGovernors returns(address){
        return deFiat_Token = _token;
    }
    function setGovernor(address _address, bool _rights) external onlyGovernors {
        require(msg.sender != _address); //prevents self stripping of rights
        deFiat_Gov[_address] = _rights;
    }
    
    function setTxTreshold(uint _amount) external onlyGovernors {
      txThreshold = _amount;  //base 1e18
    } //minimum amount of tokens to generate points per transaction
    function overrideDiscount(address _address, uint256 _newDiscount) external onlyGovernors {
      require(_newDiscount <= 100); //100 = 100% discount
      _discounts[_address]  = _newDiscount;
    }
    function overrideLoyaltyPoints(address _address, uint256 _newPoints) external onlyGovernors {
        _burn(_address, balanceOf(_address)); //burn all points
        _mint(_address, _newPoints); //mint new points
    }
    
    function setDiscountTranches(uint _tranche, uint256 _pointsNeeded) external onlyGovernors {
        require(_tranche <10, "max tranche is 9"); //tranche 9 = 90% discount
        _discountTranches[_tranche] = _pointsNeeded;
    }
    
    function setAll10DiscountTranches(
            uint256 _pointsNeeded1, uint256 _pointsNeeded2, uint256 _pointsNeeded3, uint256 _pointsNeeded4, 
            uint256 _pointsNeeded5, uint256 _pointsNeeded6, uint256 _pointsNeeded7, uint256 _pointsNeeded8, 
            uint256 _pointsNeeded9) public onlyGovernors {
        _discountTranches[0] = 0;
        _discountTranches[1] = _pointsNeeded1; //10%
        _discountTranches[2] = _pointsNeeded2; //20%
        _discountTranches[3] = _pointsNeeded3; //30%
        _discountTranches[4] = _pointsNeeded4; //40%
        _discountTranches[5] = _pointsNeeded5; //50%
        _discountTranches[6] = _pointsNeeded6; //60%
        _discountTranches[7] = _pointsNeeded7; //70%
        _discountTranches[8] = _pointsNeeded8; //80%
        _discountTranches[9] = _pointsNeeded9; //90%
    }
    
    function addPoints(address _address, uint256 _txSize, uint256 _points) external onlyToken {
       if(_txSize >= txThreshold){ _mint(_address, _points);}
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal override virtual {
        _ERC20._transfer(sender, recipient, amount);
        //force update discount
        uint256 _tranche = viewEligibilityOf(msg.sender);
        _discounts[msg.sender] =  SafeMath.mul(10, _tranche);
        
    }  //overriden to update discount at every points Transfer. Avoids passing tokens to get discounts.
    
    function burn(uint256 _amount) public returns(bool) {
        _ERC20._burn(msg.sender,_amount);
    }
} 

contract DeFiat_Gov{
    address public mastermind;
    mapping (address => uint256) private actorLevel; //governance = multi-tier level
    
    mapping (address => uint256) private _balances; 
     mapping (address => uint256) private _allowances; 
     
    uint256 private burnRate; // %rate of burn at each transaction
    uint256 private feeRate;  // %rate of fee taken at each transaction
    address private feeDestination; //target address for fees (to support staking contracts)

    event stdEvent(address _txOrigin, uint256 _number, bytes32 _signature, string _desc);

    constructor() {
        mastermind = msg.sender;
        actorLevel[mastermind] = 3;
        feeDestination = mastermind;
        emit stdEvent(msg.sender, 3, sha256(abi.encodePacked(mastermind)), "constructor");
    }

    modifier onlyMastermind {
    require(msg.sender == mastermind, " only Mastermind");
    _;
    }
    modifier onlyGovernor {
    require(actorLevel[msg.sender] >= 2,"only Governors");
    _;
    }
    modifier onlyPartner {
    require(actorLevel[msg.sender] >= 1,"only Partners");
    _;
    }  //future use
    
    function viewActorLevelOf(address _address) public view returns (uint256) {
        return actorLevel[_address]; //address lvl (3, 2, 1 or 0)
    }  
    function viewBurnRate() public view returns (uint256)  {
        return burnRate;
    }
    function viewFeeRate() public view returns (uint256)  {
        return feeRate;
    }
    function viewFeeDestination() public view returns (address)  {
        return feeDestination;
    }
    

    function setActorLevel(address _address, uint256 _newLevel) public {
      require(_newLevel < actorLevel[msg.sender], "Can only give rights below you");
      actorLevel[_address] = _newLevel; //updates level -> adds or removes rights
      emit stdEvent(_address, _newLevel, sha256(abi.encodePacked(msg.sender, _newLevel)), "Level changed");
    }
    
    //MasterMind specific 
    function removeAllRights(address _address) public onlyMastermind {
      require(_address != mastermind);
      actorLevel[_address] = 0; //removes all rights
      emit stdEvent(address(_address), 0, sha256(abi.encodePacked(_address)), "Rights Revoked");
    }
    
    function setMastermind(address _mastermind) public onlyMastermind {
      mastermind = _mastermind;     //Only one mastermind
      actorLevel[_mastermind] = 3; 
      actorLevel[msg.sender] = 2;  //new level for previous mastermind
      emit stdEvent(tx.origin, 0, sha256(abi.encodePacked(_mastermind, mastermind)), "MasterMind Changed");
    }     //only Mastermind can transfer his own rights
     
    //Governors specific
    function changeBurnRate(uint _burnRate) public onlyGovernor {
      require(_burnRate <=200, "20% limit"); //cannot burn more than 20%/tx
      burnRate = _burnRate; 
      emit stdEvent(address(msg.sender), _burnRate, sha256(abi.encodePacked(msg.sender, _burnRate)), "BurnRate Changed");
    }     //only governors can change burnRate/tx
    function changeFeeRate(uint _feeRate) public onlyGovernor {
      require(_feeRate <=200, "20% limit"); //cannot take more than 20% fees/tx
      feeRate = _feeRate;
      emit stdEvent(address(msg.sender), _feeRate, sha256(abi.encodePacked(msg.sender, _feeRate)), "FeeRate Changed");
    }    //only governors can change feeRate/tx
    function setFeeDestination(address _nextDest) public onlyGovernor {
         feeDestination = _nextDest;
    }

}

contract NewDefiatToken is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    mapping (address => uint256) private actorLevel;

    uint256 private _redisFeeOnBuy = 1;
    uint256 private _taxFeeOnBuy = 5;
    
    uint256 private _redisFeeOnSell = 1;
    uint256 private _taxFeeOnSell = 5;
    
    uint256 private _redisFee;
    uint256 private _taxFee;

    address public DeFiat_gov;      // contract governing the Token
    address public DeFiat_points;   // ERC20 loyalty TOKEN
    
    string private constant _name = "NewDefiatToken";
    string private constant _symbol = "NewDefiat";
    uint8 private constant _decimals = 9;
    
    address payable private _developmentAddress = payable(0xD4F1b63c2bb5D6eabE5729B347F5978e544A23B7);
    address payable private _marketingAddress = payable(0x315F80dbd1d88357ec8C5A70dECAD24C04a03867);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    bool private inSwap = false;
    bool private swapEnabled = true;
    
        struct Transaction {
        address sender;
        address recipient;
        uint256 burnRate;
        uint256 feeRate;
        address feeDestination;
        uint256 senderDiscount;
        uint256 recipientDiscount;
        uint256 actualDiscount;
    }
    Transaction private transaction;

    event stdEvent(address _address, uint256 _number, bytes32 _signature, string _desc);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor (address _gov, address _points) {
        _rOwned[_msgSender()] = _rTotal;

        // testnet
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        // mainnet
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_developmentAddress] = true;
        _isExcludedFromFee[_marketingAddress] = true;

        DeFiat_gov = _gov;      // contract governing the Token
        DeFiat_points = _points;   // ERC20 loyalty TOKEN

        emit Transfer(address(0x0000000000000000000000000000000000000000), _msgSender(), _tTotal);
    }

    modifier onlyDev() {	
        require(owner() == _msgSender() || _developmentAddress == _msgSender(), "Only dev");	
        _;	
    }
    modifier onlyGovernor {
        require(_msgSender() == owner() || _msgSender() == DeFiat_gov, "Only Contract Governance");
        _;
    }

    modifier onlyPoints {
        require(_msgSender() == owner() || _msgSender() == DeFiat_points, "Only Points Contract");
    _;
    }   //only Points managing contract
    
    function widthdrawAnyToken(address _recipient, address _ERC20address, uint256 _amount) public onlyGovernor returns (bool) {
        IERC20(_ERC20address).transfer(_recipient, _amount); //use of the _ERC20 traditional transfer
        return true;
    } //get tokens sent by error to contract

    function setGovernorContract(address _gov) external onlyGovernor {
        DeFiat_gov = _gov;
    }    // -> governance transfer

    function setPointsContract(address _pts) external onlyGovernor {
        DeFiat_points = _pts;
    }      // -> new points management contract

        function _viewFeeRate() public view returns(uint256){
       return DeFiat_Gov(DeFiat_gov).viewFeeRate();
    }
    function _viewBurnRate() public view returns(uint256){
        return DeFiat_Gov(DeFiat_gov).viewBurnRate();
    }
    function _viewFeeDestination() public view returns(address){
        return DeFiat_Gov(DeFiat_gov).viewFeeDestination();
    }
    function _viewDiscountOf(address _address) public view returns(uint256){
        return DeFiat_Points(DeFiat_points).viewDiscountOf(_address);
    }
    function _viewPointsOf(address _address) public view returns(uint256){
        return DeFiat_Points(DeFiat_points).balanceOf(_address);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

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

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        _redisFee = 0;
        _taxFee = 0;
        
        if (from != owner() && to != owner()) {
            
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != uniswapV2Pair && swapEnabled && contractTokenBalance > 0) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
            
            if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnBuy;
                _taxFee = _taxFeeOnBuy;
            }
    
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnSell;
                _taxFee = _taxFeeOnSell;
            }
            
            if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
                _redisFee = 0;
                _taxFee = 0;
            }
            
        }

        _tokenTransfer(from,to,amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
        
    function sendETHToFee(uint256 amount) private {
        _developmentAddress.transfer(amount.div(2));
        _marketingAddress.transfer(amount.div(2));
    }
    
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        _transferStandard(sender, recipient, amount);
    }

    event tokensRescued(address indexed token, address indexed to, uint amount);
    function rescueForeignTokens(address _tokenAddr, address _to, uint _amount) public onlyDev() {
        emit tokensRescued(_tokenAddr, _to, _amount);	
        Token(_tokenAddr).transfer(_to, _amount);
    }
    
    event devAddressUpdated(address indexed previous, address indexed adr);
    function setNewDevAddress(address payable dev) public onlyDev() {
        emit devAddressUpdated(_developmentAddress, dev);	
        _developmentAddress = dev;
        _isExcludedFromFee[_developmentAddress] = true;
    }
    
    event marketingAddressUpdated(address indexed previous, address indexed adr);
    function setNewMarketingAddress(address payable markt) public onlyDev() {
        emit marketingAddressUpdated(_marketingAddress, markt);	
        _marketingAddress = markt;
        _isExcludedFromFee[_marketingAddress] = true;
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount); 
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate =  _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    receive() external payable {}
    
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(tAmount, _redisFee, _taxFee);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTeam, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }

    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 TeamFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tTeam = tAmount.mul(TeamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

	function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function manualswap() external {
        require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress || _msgSender() == owner());
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualsend() external {
        require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress || _msgSender() == owner());
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
    
    function setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyDev {
	    require(redisFeeOnBuy < 11, "Redis cannot be more than 10.");
	    require(redisFeeOnSell < 11, "Redis cannot be more than 10.");
	    require(taxFeeOnBuy < 7, "Tax cannot be more than 6.");
	    require(taxFeeOnSell < 7, "Tax cannot be more than 6.");
        _redisFeeOnBuy = redisFeeOnBuy;
        _redisFeeOnSell = redisFeeOnSell;
        _taxFeeOnBuy = taxFeeOnBuy;
        _taxFeeOnSell = taxFeeOnSell;
    }
    
    function toggleSwap(bool _swapEnabled) public onlyDev {
        swapEnabled = _swapEnabled;
    }

    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
}