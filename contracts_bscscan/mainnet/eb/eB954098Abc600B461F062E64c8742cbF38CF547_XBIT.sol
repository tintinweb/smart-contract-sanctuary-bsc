// SPDX-License-Identifier: MIT 
pragma solidity ^0.6.12;

import "./interfaceIBEP20.sol";
import "./librarySafeMath.sol";
import "./libraryAddress.sol";
import "./interfaceIUniswapV2Factory.sol";

abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
        
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract XBIT is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    struct TraderInfo {
        uint256 lastTrade;
        uint256 amount;
    }

    string private _name = "X-Bit Cash"; // Representa o nome da moeda
    string private _symbol = "XBIT"; // Represanta o simbolo da moeda
    
    uint8 private _decimals = 18; // Casas decimais por bloco

    bool public isAntiWhale; 
    uint256 public maxTxAmount = _tokenTotal; // Limita compra e venda da moeda em quantias iguais por TX.
    uint256 public maxSell = _tokenTotal * 10**uint256(_decimals); // Limita a venda da moeda em uma quantia determinada por transação.
    uint256 public purchaseAmount = 100 * 10**uint256(_decimals); // Limita a compra minima da moeda em uma quantia determinada por transação.
    uint256 public antiWhaleSellEnd; // timestamp
    
    mapping(address => mapping(string => TraderInfo)) private traders;

    mapping(address => bool) public blacklist;
    mapping(address => bool) public whitelist;

    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _tokenBalance;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => uint256) private _balances;

    event SetAntiWhale(bool IsAntiWhale);
    event SetMaxSell(uint256 MaxSell);
    event Setpurchase(uint256 purchaseAmount);
    event SetAntiWhaleEnd(uint256 AntiWhaleSellEnd);

    uint256 private constant MAX = ~uint256(0);
    uint256 internal _tokenTotal = 300000000e18; // 600 Milhões e18 decimais.
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));

    mapping(address => bool) isTaxless; 
    mapping(address => bool) internal _isExcluded; 
    address[] internal _excluded;
    
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }

    // Definição de taxas por casa decimal sendo 1%=100 /2%=200/3%=300 /4%=400/ 5%=500
    uint256 public _taxaDecimal = 2;
    
    uint256 public _holderFee = 0;
    uint256 public _holderFeeTotal;
    
    // liquidez %
    uint256 public _liquidityFee = 2;
    uint256 public _liquidityFeeTotal;

    // queima %
    uint256 public _burnFee = 0;
    uint256 public _burnFeeTotal;
    
    // devWallet %
    uint256 public _devFee = 1;
    uint256 public _devFeeTotal;

    // marketWallet %
    uint256 public _marketFee = 1;
    uint256 public _marketFeeTotal;
    
    // identificação de carteiras publicas
    address public devWallet;
    address public marketWallet;
    address public burnAccount;
    
    bool public isTaxActive = true;
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    // Reserva o montante para adicionar a liquidez.
    uint256 public minTokensBeforeSwap = 5000000e18; 

    IUniswapV2Router02 public  uniswapV2Router;
    address public  uniswapV2Pair;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() public {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        devWallet = 0x16f080E983998d88B39EA2Ac14dB77B3dDC14a12;
        
        marketWallet = 0x72c643F9E30B1147D2C9E000dc3C1483bf48bCEE;
        
        burnAccount = address(0);
        isTaxless[_msgSender()] = true;
        isTaxless[address(this)] = true;
        _reflectionBalance[_msgSender()] = _reflectionTotal;
        emit Transfer(address(0), _msgSender(), _tokenTotal);
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

    function totalSupply() public override view returns (uint256) {
        return _tokenTotal;
    }

    function balanceOf(address account) public override view returns (uint256) {
        if (_isExcluded[account]) return _tokenBalance[account];
        return tokenFromReflection(_reflectionBalance[account]);
    }
    
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {
       _transfer(_msgSender(),recipient,amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        override
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        whenNotPaused
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function burn(uint256 amount) external {
    _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {
    require(account != address(0), "XBIT: burn from the zero address");
    _tokenBalance[account] = _tokenBalance[account].sub(amount, "XBIT: burn amount exceeds balance");
    _tokenTotal = _tokenTotal.sub(amount);
    emit Transfer(account, address(0), amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(
      account,
      _msgSender(),
      _allowances[account][_msgSender()].sub(amount, "XBIT: burn amount exceeds allowance")
    );
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {
        _transfer(sender,recipient,amount);
               
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub( amount,"XBIT: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        whenNotPaused
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
        whenNotPaused
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "XBIT: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tokenAmount <= _tokenTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            return tokenAmount.mul(_getReflectionRate());
        } else {
            return
                tokenAmount.sub(tokenAmount.mul(_holderFee).div(10** _taxaDecimal + 2)).mul(
                    _getReflectionRate()
                );
        }
    }

    function tokenFromReflection(uint256 reflectionAmount)
        public
        view
        returns (uint256)
    {
        require(
            reflectionAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getReflectionRate();
        return reflectionAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(
            account != address(uniswapV2Router),
            "XBIT: We can not exclude Uniswap router."
        );
        require(!_isExcluded[account], "XBIT: Account is already excluded");
        if (_reflectionBalance[account] > 0) {
            _tokenBalance[account] = tokenFromReflection(
                _reflectionBalance[account]
            );
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "XBIT: Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalance[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "XBIT: approve from the zero address");
        require(spender != address(0), "XBIT: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "XBIT: transfer from the zero address");
        require(recipient != address(0), "XBIT: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount >= purchaseAmount, "Transfer amount must be greater than the purchaseAmount!");

        require(amount <= maxTxAmount, "Transfer Limit exceeded maxTxAmount!");
        require(amount <= maxSell, "Transfer Limit exceeded maxSell!");

        require(!blacklist[sender] && !blacklist[recipient],"anti bot");
        if (isAntiWhale) {
            antiWhale(sender, amount);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= minTokensBeforeSwap;
        if (!inSwapAndLiquify && overMinTokenBalance && sender != uniswapV2Pair && swapAndLiquifyEnabled) {
            swapAndLiquify(contractTokenBalance);
        }

        uint256 transferAmount = amount;
        uint256 rate = _getReflectionRate();

        if(isTaxActive && !isTaxless[_msgSender()] && !isTaxless[recipient] && !inSwapAndLiquify){
            transferAmount = collectFee(sender,amount,rate);
        }
        
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(amount.mul(rate));
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(transferAmount.mul(rate));

        if (_isExcluded[sender]) {
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tokenBalance[recipient] = _tokenBalance[recipient].add(transferAmount);
        }

        emit Transfer(sender, recipient, transferAmount);
    }
    
    function collectFee(address account, uint256 amount, uint256 rate) private returns (uint256) {
        uint256 transferAmount = amount;
        
        if(_holderFee != 0){
            uint256 holderFee = amount.mul(_holderFee).div(10**(_taxaDecimal + 2));
            transferAmount = transferAmount.sub(holderFee);
            _reflectionTotal = _reflectionTotal.sub(holderFee.mul(rate));
            _holderFeeTotal = _holderFeeTotal.add(holderFee);
        }
    
        if(_liquidityFee != 0){
            uint256 liquidityFee = amount.mul(_liquidityFee).div(10**(_taxaDecimal + 2));
            transferAmount = transferAmount.sub(liquidityFee);
            _reflectionBalance[address(this)] = _reflectionBalance[address(this)].add(liquidityFee.mul(rate));
            if(_isExcluded[address(this)]){
                _tokenBalance[address(this)] = _tokenBalance[address(this)].add(liquidityFee);
            }
            _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account,address(this),liquidityFee);
        }
    
        if(_burnFee != 0){
            uint256 burnFee = amount.mul(_burnFee).div(10**(_taxaDecimal + 2));
            transferAmount = transferAmount.sub(burnFee);
            _reflectionBalance[burnAccount] = _reflectionBalance[burnAccount].add(burnFee.mul(rate));
            if (_isExcluded[burnAccount]) {
                _tokenBalance[burnAccount] = _tokenBalance[burnAccount].add(burnFee);
            }
            _burnFeeTotal = _burnFeeTotal.add(burnFee);
            emit Transfer(account,burnAccount,burnFee);
        }
        
        if(_marketFee != 0){
            uint256 marketFee = amount.mul(_marketFee).div(10**(_taxaDecimal + 2));
            transferAmount = transferAmount.sub(marketFee);
            _reflectionBalance[marketWallet] = _reflectionBalance[marketWallet].add(marketFee.mul(rate));
            if (_isExcluded[marketWallet]) {
                _tokenBalance[marketWallet] = _tokenBalance[marketWallet].add(marketFee);
            }
            _marketFeeTotal = _marketFeeTotal.add(marketFee);
            emit Transfer(account,marketWallet,marketFee);
        }
    
        if(_devFee != 0){
            uint256 devFee = amount.mul(_devFee).div(10**(_taxaDecimal + 2));
            transferAmount = transferAmount.sub(devFee);
            _reflectionBalance[devWallet] = _reflectionBalance[devWallet].add(devFee.mul(rate));
            if (_isExcluded[devWallet]) {
                _tokenBalance[devWallet] = _tokenBalance[devWallet].add(devFee);
            }
            _devFeeTotal = _devFeeTotal.add(devFee);
            emit Transfer(account,devWallet,devFee);
        }
        
        return transferAmount;
    }
    
    function _getReflectionRate() private view returns (uint256) {
        uint256 reflectionSupply = _reflectionTotal;
        uint256 tokenSupply = _tokenTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalance[_excluded[i]] > reflectionSupply ||
                _tokenBalance[_excluded[i]] > tokenSupply
            ) return _reflectionTotal.div(_tokenTotal);
            reflectionSupply = reflectionSupply.sub(
                _reflectionBalance[_excluded[i]]
            );
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);
        }
        if (reflectionSupply < _reflectionTotal.div(_tokenTotal))
            return _reflectionTotal.div(_tokenTotal);
        return reflectionSupply.div(tokenSupply);
    }
    
     function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
         if(contractTokenBalance > maxTxAmount)
            contractTokenBalance = maxTxAmount;
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);


        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half); 

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(this),
            block.timestamp
        );
    }
    
    function setAntiWhale(bool _isAntiWhale) external onlyOwner {
        isAntiWhale = _isAntiWhale;
        emit SetAntiWhale(_isAntiWhale);
    }

    function antiWhale(
        address _sender,
        uint256 _amount
    ) internal {

      uint256 curTime = block.timestamp;
      if (curTime < antiWhaleSellEnd && !whitelist[_sender]) {
        if (_amount > maxSell) {
          revert("Anti whale sell");
        }
        else if (traders[_sender]["SELL"].lastTrade == 0) {
            traders[_sender]["SELL"] = TraderInfo({
                lastTrade: curTime,
                amount: _amount
            });
        } else {
            revert("Wait for next trade");
        }
      }
    }

    function setMaxSell_and_purchaseAmount (uint256 _maxSell, uint256 _purchaseAmount) external onlyOwner {
        maxSell = _maxSell;
        emit SetMaxSell(_maxSell);
        purchaseAmount = _purchaseAmount;
        emit Setpurchase(_purchaseAmount);
    }

    function setAntiWhaleEnd(uint256 _antiWhaleSellEnd) external onlyOwner {
        antiWhaleSellEnd = _antiWhaleSellEnd;
        emit SetAntiWhaleEnd(_antiWhaleSellEnd);
    }

    function setPair(address pair) external onlyOwner {
        uniswapV2Pair = pair;
    }
    
    function setdevWallet(address account) external onlyOwner {
        devWallet = account;
    }

    function setmarketWalet(address account) external onlyOwner {
        marketWallet = account;
    }

    function setburnAccount(address account) external onlyOwner {
        burnAccount = account;
    }

    function setTaxless(address account, bool value) external onlyOwner {
        isTaxless[account] = value;
        
    }
    
    function setWhitelist(address _addr, bool _isWL) external onlyOwner {
        whitelist[_addr] = _isWL;
        isTaxless[address(this)] = true;
    }

    function multiBlacklist(address[] memory addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            blacklist[addresses[i]] = true;
        }
    }

    function multiRemoveFromBlacklist(address[] memory addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            blacklist[addresses[i]] = false;
        }
    }

    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }
    
    function setTaxActive(bool value) external onlyOwner {
        isTaxActive = value;
    }
    
    function setholderFee(uint256 fee) external onlyOwner {
        _holderFee = fee;
    }
    
    function setBurnFee(uint256 fee) external onlyOwner {
        _burnFee = fee;
    }
    
    function setLiquidityFee(uint256 fee) external onlyOwner {
        _liquidityFee = fee;
    }
 
    function setdevFee(uint256 fee) external onlyOwner {
        _devFee = fee;
    }
    function setmarketFee(uint256 fee) external onlyOwner {
        _marketFee = fee;
    }
    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount;
    }
    
    function setMinTokensBeforeSwap(uint256 amount) external onlyOwner {
        minTokensBeforeSwap = amount;
    }
    
    function rescueStuckIERC20(address _token) external onlyOwner {
        uint256 _amount = XBIT (_token).balanceOf(address(this));
        XBIT (_token).transfer(owner(), _amount);
    }
    //receive() external payable {}
}