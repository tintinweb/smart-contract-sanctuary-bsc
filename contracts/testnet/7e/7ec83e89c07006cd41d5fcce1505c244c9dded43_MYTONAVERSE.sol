/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-30
*/

pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier:MIT

// BEP20 token standard interface
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Dex Factory contract interface
interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// Dex Router02 contract interface
interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// Main token Contract

contract MYTONAVERSE is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    // all private variables and functions are only for contract use
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 10 * 10 ** 7 * 10 ** 6; // 100 Million total supply
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "MYTONAVERSE"; // token name
    string private _symbol = "TONA"; // token ticker
    uint8 private _decimals = 6; // token decimals

    IDexRouter public dexRouter; // Dex router address
    address public dexPair; // LP token address
    
    address payable public liquidityPool; // liquidity pool wallet

    //distribution wallets
    address payable public wallet1;
    address payable public wallet2;
    address payable public wallet3;
    address payable public wallet4;
    //initial holders wallet
    address payable public wallet5;
    address payable public wallet6;
    address payable public wallet7;
    address payable public wallet8;

    bool public reflectionFees = true; // should be false to charge fee

    // Normal sell tax fee
    uint256 public _sellReflectionFee = 20; // 2% will be distributed among holder as token divideneds
    uint256 public _sellWallet3Fee = 40; // 4% goes to the wallet 3
    uint256 public _sellWallet4Fee = 20; // 2% goes to the wallet 4

    //normal buy tax fee
    uint256 public _buyReflectionFee = 10; // 1% will go to the reflection
    uint256 public _buyWallet1Fee = 10; // 1% goes to the wallet 1 
    uint256 public _buyWallet2Fee = 10; // 1% goes to the wallet 2


    // for smart contract use
    uint256 private _currentReflectionFee;
    uint256 private _currentWallet13Fee;
    uint256 private _currentWallet24Fee;
    bool private _isBuy = false;

    // constructor for initializing the contract
    constructor( ) {
        uint256 Distribution20 = _tTotal.mul(20).div(100);
        uint256 Distribution40 = _tTotal.mul(40).div(100);
        
        //distribution wallets
        wallet1 =payable(0x4299bC9538dA3242815F993d94518Bd087DDb5D2);
        wallet2 = payable(0x2546166e86E0c9A37C6C3A7643Aa669d5c48a08A);
        wallet3 = payable(0x4299bC9538dA3242815F993d94518Bd087DDb5D2);
        wallet4 = payable(0x95792Bc9eb5EDfa512A3AdB231F02111b6fA9876);

        // //initial holders wallet 
        wallet5 = payable(0x23B6c211f3934D645bCF13aCb9590396AfD73d5C);
        wallet6 = payable(0x4299bC9538dA3242815F993d94518Bd087DDb5D2);
        wallet7 = payable(0x95792Bc9eb5EDfa512A3AdB231F02111b6fA9876);
        wallet8 = payable(0x2546166e86E0c9A37C6C3A7643Aa669d5c48a08A);
        
        _rOwned[wallet5] = Distribution40;
        _rOwned[wallet6] = Distribution20;
        _rOwned[wallet7] = Distribution20;
        _rOwned[wallet8] = Distribution20;

        liquidityPool = payable(0x57cEBBE620d575914fddc17eD1c5Ec382497CED6);

        IDexRouter _dexRouter = IDexRouter(
            //  0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 //pancakeswap mainnet router
           0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 //pancakeswap testnet router
        );
        // Create a Dex pair for this new token
        dexPair = IDexFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );

        // set the rest of the contract variables
        dexRouter = _dexRouter;

        // exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), wallet5, Distribution40);
        emit Transfer(address(0), wallet6, Distribution20);
        emit Transfer(address(0), wallet7, Distribution20);
        emit Transfer(address(0), wallet8, Distribution20);
    }

    // token standards by Blockchain
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address _account)
        public
        view
        override
        returns (uint256)
    {
        return tokenFromReflection(_rOwned[_account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    // public view able functions

    // to check wether the address is excluded from fee or not
    function isExcludedFromFee(address _account) public view returns (bool) {
        return _isExcludedFromFee[_account];
    }

    // to check how much tokens get redistributed among holders till now
    function totalHolderDistribution() public view returns (uint256) {
        return _tFeeTotal;
    }

    // For manual distribution to the holders
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        uint256 rAmount = tAmount.mul(_getRate());
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "BEP20: Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    //to receive BNB from dexRouter when swapping
    receive() external payable {}

    // internal functions for contract use

    function totalFeePerTx(uint256 tAmount) internal view returns (uint256) {
        uint256 percentage = tAmount
            .mul(
                _currentReflectionFee
                    .add(_currentWallet24Fee)
                    .add(_currentWallet13Fee)
            )
            .div(1e3);
        return percentage;
    }

    function _getRate() private view returns (uint256) {
        return _rTotal.div(_tTotal);
    }

    function removeAllFee() private {
        _currentReflectionFee = 0;
        _currentWallet24Fee = 0;
        _currentWallet13Fee = 0;
    }

    function setSellFee() private {
        _currentReflectionFee = _sellReflectionFee;
        _currentWallet24Fee = _sellWallet4Fee;
        _currentWallet13Fee = _sellWallet3Fee;
    }

    function setBuyFee() private {
        _currentReflectionFee = _buyReflectionFee;
        _currentWallet24Fee = _buyWallet2Fee;
        _currentWallet13Fee = _buyWallet1Fee;
    }

     // owner can change WalletAddress
    function updateWalletAddresses(address payable _liquidityPool,address payable _wallet1Address,address payable _wallet2Address,address payable _wallet3Address,address payable _wallet4Address)
        external
        onlyOwner
    {
        liquidityPool = _liquidityPool;
        wallet1  = _wallet1Address;
        wallet2  = _wallet2Address;
        wallet3  = _wallet3Address;
        wallet4  = _wallet4Address;
    }
    
     // owner can change router and pair address
    function setRoute(IDexRouter _router, address _pair) external onlyOwner {
        dexRouter = _router;
        dexPair = _pair;
    }
    
    //input 10 for 1 percent
    function setSellRedistributionFee(uint256 _fee) external onlyOwner {
        _sellReflectionFee = _fee;
    }

    //input 10 for 1 percent
    function _setWallet4Fee(uint256 _wallet4Fee) external onlyOwner {
        _sellWallet4Fee = _wallet4Fee;
    }

    //input 10 for 1 percent    
    function _setWallet3Fee(uint256 _wallet3Fee) external onlyOwner {
        _sellWallet3Fee = _wallet3Fee;
    }

    //input 10 for 1 percent    
    function _setWallet1Fee(uint256 _wallet1Fee) external onlyOwner{
        _buyWallet1Fee = _wallet1Fee;
    }

    //input 10 for 1 percent    
    function _setWallet2Fee(uint256 _wallet2Fee) external onlyOwner{
        _buyWallet2Fee = _wallet2Fee;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // base function to transafer tokens
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any _account belongs to _isExcludedFromFee _account then remove the fee
        if (
            _isExcludedFromFee[from] ||
            _isExcludedFromFee[to] ||
            !reflectionFees
        ) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
      removeAllFee();

      if(recipient == dexPair && takeFee){
        _isBuy = false;
        setSellFee();
      }
      if(sender == dexPair && takeFee){
        _isBuy = true;
        setBuyFee();
      }

      _transferStandard(sender, recipient, amount);
    }

    // if both sender and receiver are not excluded from reward
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 tTransferAmount = tAmount.sub(totalFeePerTx(tAmount));
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(
            totalFeePerTx(tAmount).mul(currentRate)
        );
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeWallet24Fee(sender, tAmount, currentRate);
        _takeWallet13Fee(sender, tAmount, currentRate);
        _reflectFee(tAmount);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    // take fees for wallet4
    function _takeWallet24Fee(
        address sender,
        uint256 tAmount,
        uint256 currentRate
    ) internal {
        uint256 tFee = tAmount.mul(_currentWallet24Fee).div(1e3);
        uint256 rFee = tFee.mul(currentRate);
        _rOwned[wallet4] = _rOwned[wallet4].add(rFee);

        emit Transfer(sender, wallet4, tFee);
    }

    // take fees for market wallet
    function _takeWallet13Fee(
        address sender,
        uint256 tAmount,
        uint256 currentRate
    ) internal {
        uint256 tFee = tAmount.mul(_currentWallet13Fee).div(1e3);
        uint256 rFee = tFee.mul(currentRate);
        if(_isBuy){
          _rOwned[wallet1] = _rOwned[wallet1].add(rFee);
          emit Transfer(sender, wallet1, tFee);
        }else{
          _rOwned[wallet3] = _rOwned[wallet3].add(rFee);
          emit Transfer(sender, wallet3, tFee);
        }

    }

    // for automatic redistribution among all holders on each tx
    function _reflectFee(uint256 tAmount) private {
        uint256 tFee = tAmount.mul(_currentReflectionFee).div(1e3);
        uint256 rFee = tFee.mul(_getRate());
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}